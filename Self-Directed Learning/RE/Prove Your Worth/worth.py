# coding: utf-8
from pwn import *
p = remote('3qo9k5hk5cprtqvnlkvotlnj9d14b7mt.ctf.sg', 40101)

p.send('10 52 62 114 176')  # levelone
log.info("LEVEL 1")

v2 = [103, 34, 105, 109, 121, 97, 37, 110, 111, 110, 96, 96, 122, 120]
v3 = [73, -16, -104, 49, -44, -27, -80, 29, -97, -18, -76, -95, 105, -61]
v2i = []
v3i = []
final = []
c1 = ''

for i in v2:
    i = int(i)
    v2i.append(i & 0xF0)

for j in v3: 
    j = int(j)
    v3i.append(j & 0xF)

while v2i:
    x = v2i.pop(0)
    y = v3i.pop(0)
    c1 += chr(x ^ y)
p.sendline(c1)

log.info("LEVEL 3")
s = process('./rand.elf')
rand = []
anss = []

for i in range(5):
    rand.append(s.recvline().rstrip(b'\n'))

for j in rand:
    ans = 15 - int(j)
    anss.append(str(ans))

ans = ' '.join(anss[::-1])
p.clean()
p.sendline(ans)
p.interactive()
