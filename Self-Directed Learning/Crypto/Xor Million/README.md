# Xor Million

---

### Challenge Description

> I've encrypted the flag and given it to you. This time i've used a stronger encryption! My key is now longer, and i've XOR-ed the thing a million times. SURELY this must be hard to decrypt.

> Concept(s) Required: XOR

[xormillion.zip](https://github.com/caprinux/Cyberthon-2021-Training/files/6369146/xormillion.zip)

---

### Solution

Taking a look at the encryption script, we see that the flag was encrypted 1000000 times with a random key of length 5 that isn't constant.

However, this is not a worry and should not be a distraction. A file that is xored with 100000 different length 5 keys is the same as a file that is xored with 1 random length 5 key.

A length 5 key will also take too long to break and is definitely not the intended solution. Many participants went onto cyberchef and some even crashed their chromes.

Anyways in order to break this, you have to understand about the xor properties, you can read more [here](https://accu.org/journals/overload/20/109/lewin_1915/).

The most important property for this challenge is the commutative property.

Just to quickly summarise: 

```
If A ⊕ B = C
then C ⊕ B = A
and C ⊕ A = B
```

Since we know that the flag handle is **CTFSG{** and is definitely the first 6 characters of plaintext, we can xor **CTFSG{** against the encrypted text to get our key.

And then use our key to fully decrypt the encrypted text.

Let's write our script.

```py
from pwn import * # pwntools has an amazing xor function

encrypted = open('flag.txt.encrypted', 'rb').read()

key = xor(encrypted, 'CTFSG{')[:5]

print(xor(key, encrypted))
```

output:
```
CTFSG{w0w_th4t_w45_4ctu4lly_r34lly_u53l355}
```
