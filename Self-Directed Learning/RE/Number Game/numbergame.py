# coding: utf-8
import re
encrypted = open('flag.txt.encrypted', 'r').read()
encrypted = list(str(encrypted))
plaintext = ''

for i in range(24):
    while encrypted:
        counter = encrypted.pop(0)
        character = encrypted.pop(0)
        counter = int(counter)
        plaintext += counter * character
    encrypted = list(str(plaintext))
    plaintext = ''

decoded = ''.join(encrypted)
flag = re.findall('...',decoded)
for i in flag:
    i = int(i.lstrip('0'),10)
    print(chr(i), end='')
    
