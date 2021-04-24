# Really Secure Algorithm

---

###Challenge Description

> What happens when you've got a flag encrypted with RSA but you've got no private key, only the public key and the two primes? Is it even possible to decrypt the flag??

> Concept(s) Required: RSA, EGCD, Inverse Mod

[reallysecurealgorithm.zip](https://github.com/caprinux/Cyberthon-2021-Training/files/6369177/reallysecurealgorithm.zip)

---

### Solution

This is really straightforward. In the `rsa.txt`, we are given the 2 primes, and the public key.

With the two primes we can calculate the totient. 

And with the totient and public key, we can calculate the private key.

With the private key, cipher text, and two primes, we can decrypt the message.

Let's script this.

```py
from Crypto.Util.number import *
c = open('flag.txt.encrypted', 'rb').read()
c = bytes_to_long(c)
p = 163457106450783445806665763936840795224335118638688747118145262051536966852927178714354472420894161567345798876484431370418160230276680030234659674821189812953137829238466457790011401311065933161137619929619240992208932900359653100522606364930588672146004948494703010403785602523382411941848901725348597907089
q = 169092937488173601150107963609235159099068030966810117600280934194940989117225047356630083642289619557970268922961226770984214401901054922632851546963233694621594948971464931017385316063330450260229563385896256150161969568316042071516610553055735726314300969140360092385383098597756071675521622606699780460681
e = 65537

n = p*q

phi = (p-1) * (q-1)

d = pow(e, -1, phi)

m = pow(c, d, n)

print(long_to_bytes(m))
```

```
CTFSG{r54_15_45ymm3tr1c_3ncrypt10n}
```
