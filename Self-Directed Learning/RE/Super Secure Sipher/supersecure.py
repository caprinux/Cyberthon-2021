from pwn import *
enc = open('flag.txt.out', 'r').read()
var1= list(enc[:1])
var2= list(enc[1:])
flag = b''
z = 0 # var5 = 0

while var2:
    x = var1 			# x = var1
    y = var2.pop(0) 		# y = var1 ^ var5
    var5 = xor(x, y) 		# var5 = var1 ^ (var1 ^ var5)    
    char = xor(var5, z) 	# char of flag = var5 ^ var5
    z = xor(char, z) 		# update var5, var5 = var5 ^ flag
    flag += char		# append flag
flag += b"}"
print(flag)
    