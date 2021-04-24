# Hashcryption

---

### Challenge Description

> AES ECB mode isn't very secure. But surely when I combine it with hashing it's going to be secure right? I'm so confident that i've even deployed a network service that allows you to do your own encryption using this technique!

> Interact with the service at: 3qo9k5hk5cprtqvnlkvotlnj9d14b7mt.ctf.sg:10101

> Concept(s) Required: AES ECB, MD5

[hashcryption.zip](https://github.com/caprinux/Cyberthon-2021-Training/files/6369198/hashcryption.zip)

---

### Solution

```py
#! /usr/bin/python3

from Crypto.Hash import MD5
from Crypto.Cipher import AES
from binascii import unhexlify
import sys


KEY = open('aeskey', 'rb').read()


def read(prompt):
    write(prompt)
    data = sys.stdin.buffer.read()
    write('\n')

    return data


def write(prompt):
    try:
        sys.stdout.buffer.write(prompt)
    except TypeError:
        sys.stdout.buffer.write(prompt.encode('utf-8'))

    sys.stdout.flush()


def md5sum(data):
    md5 = MD5.new()
    md5.update(data)

    return md5.hexdigest()


def md5ify(data):
    return unhexlify(''.join([md5sum(bytes([byte])) for byte in data]))


def encrypt(data, key):
    hashed_data = md5ify(data)
    cipher = AES.new(key, AES.MODE_ECB)

    return cipher.encrypt(hashed_data)

data = read('[+] Data: ')
write('[+] Encrypted:\n')
write('----------------------------- START -------------------------------\n')
write(encrypt(data, KEY))
write('\n------------------------------ END --------------------------------')
```

The server-side encryption script is rather straightforward. It takes in an input, it hashes each character of the input with MD5, and then it encrypts it with an unknown AES key.

Something worth noting is that the hash size for MD5 is 128 bits, and that AES is also a 128-bit block cipher.

This means that each character that we send to the server will be encrypted into 1 block. 

Since AES_ECB is being used, and it does not have any sort of IV, any character sent will always give the same output.

What we can do is to send all the alphabets to the server, and then put it against its correspoding character in a dictionary.

We can then compare the dictionary with the encrypted flag to decrypt it into its respective letters, obtaining the flag.

Let's write a script for this.

```py
# coding: utf-8
from pwn import *
from Crypto.Hash import MD5
from binascii import unhexlify

letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890{}_"

alphadict = {}

for letter in letters:
    p = remote('3qo9k5hk5cprtqvnlkvotlnj9d14b7mt.ctf.sg', 10101)
    p.recvuntil("Data: ")
    p.send(letter)
    p.shutdown()
    p.recvline()
    p.recvline()
    p.recvline()
    leak = p.recvline().rstrip(b'\n')
    hexleak = leak.hex()
    alphadict[hexleak] = letter


enc = open('flag.txt', 'rb').read().hex()
enc = ' '.join(enc[i:i + 32] for i in range(0, len(enc), 32))

for i in list(enc.split(" ")):
    if i in alphadict:
        print(alphadict[i], end='')
```

It will take awhile as it connects to the server multiple times, however you can actually send all the letters at once too, albeit a little more work.

We get out output 

```
CTFSGr0ng_m0d3_m1gh_45_3ll_d0n_3ncryp}
```

However, something went wrong and some letters are not printing well. But it is enough to decipher the full flag.

```
CTFSG{wr0ng_m0d3_m1ght_45_w3ll_d0nt_3ncrypt}
```

---

### Extras

I actually wrote a script to connect to the server and send an input since the server was a little troublesome as you have to send a shutdown signal to send ur input.

```py
from pwn import *
from Crypto.Hash import MD5
from binascii import *

p = remote('3qo9k5hk5cprtqvnlkvotlnj9d14b7mt.ctf.sg', 10101)
p.recvuntil('Data: ')
log.info("Key in your input:")
input = input().rstrip('\n').encode()
log.info(b"Input: " + input)
log.info("Sending " + str(len(input)) + " characters of data...")
p.send(input)
p.shutdown()
p.recvline()
p.recvline()
p.recvline()

def md5sum(data):
    md5 = MD5.new()
    md5.update(data)

    return md5.hexdigest()

def md5ify(data):

    return unhexlify(''.join([md5sum(bytes([byte])) for byte in data]))

input = md5ify(input)

leak = p.recvline().strip(b"\n")
log.info("Output (in hex): " + str(leak.hex()) + "\n")
log.info("After hashing, your input(in hex) was " + str(input.hex()) + ".")
log.info("Your input was " + str(len(input)) + " bytes long\n")
```




