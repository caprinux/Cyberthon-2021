# coding: utf-8
flag = '3rmt345vR'
print("CTFSG{", end='')
for i in flag:
    add = ord(i) - 3
    print(chr(add), end='')
print("}", end='')
