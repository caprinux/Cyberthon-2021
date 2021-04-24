# Xor Million

---

### Challenge Description

> I've encrypted the flag and given it to you. All you have to do is decrypt it!

> Concept(s) Required: Shift ciphers

[byterotater.zip](https://github.com/caprinux/Cyberthon-2021-Training/files/6369136/byterotater.zip)

---

### Solution

We are provided with a ``flag.jpg.encrypted``.

We hexdump the encrypted flag.jpg file:

![image](https://user-images.githubusercontent.com/76640319/115951310-aae41200-a512-11eb-9f27-9a83751ca876.png)

As you can see the bytes are very off, and the magic bytes are wrong. Let's fix this.

First, we find out what are the magic bytes for jpg, that can be easily found on [wiki](https://en.wikipedia.org/wiki/List_of_file_signatures). 

![image](https://user-images.githubusercontent.com/76640319/115951337-d0711b80-a512-11eb-845f-0df9903c9726.png)

As you can see, the first 2 bytes should be **FF D8**. Instead, we have **2b 04**. 

Since the challenge mentioned some sort of shift, lets see if we can find the offset.

![image](https://user-images.githubusercontent.com/76640319/115951370-00b8ba00-a513-11eb-9b9d-481c7ebdee98.png)

As you can see, the offset is 212 and testing the offset with the next wrong byte give us the correct byte.

Let's now write a short script to solve this:

```py

enc = open('flag.jpg.encrypted', 'rb').read()
f = open('fleg.jpg', 'wb')

for i in enc:
    plain = (i + 212) % 256
    plain = plain.to_bytes(1, byteorder='big')
    f.write(plain)
f.close()
```

We open our plaintext .jpg file.

![fleg](https://user-images.githubusercontent.com/76640319/115951400-26de5a00-a513-11eb-9ff7-d1c9f870f4ba.jpg)

```
CTFSG{b1gg3r_sh1ft5_m0r3_s3cur3}
```
