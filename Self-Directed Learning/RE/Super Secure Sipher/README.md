# Super Secure Sipher

---

### Challenge Description

> Not again? Seems like this flag has been encrypted by a Java program. Let's write a script to decrypt it!

> Concept(s) Required: Reversing Java class files, Properties of XOR

---

### Solution

We are provided with a java class file. We decompile it using an online decompiler, [jdec](jdec.app).

After some cleaning up and some annotation we have this:

```java
   public static String encrypt(String var0) {
      String var1 = "";
      SecureRandom var2 = randomGenerator();
      if (var2 == null) {
         System.exit(0);
      }

      int var3 = 0;

      int var4;
      for(var4 = 0; var4 < 256; ++var4) {
         var3 ^= var2.nextInt(256);                             # var3 is random number in range 0-256
      }

      var4 = var3;                                              # var 4 is a random number in range 0-256                                             

      int var6;
      for(i=0; var6 = var0.length(); i < var6; ++i) {
         var4 ^= var0.charAt(i);                                # each character in flag is xored by random number
      }

      var1 = var1 + (char)var4;                                 # var1 = (char)var4
      var5 = 0;
      var6 = 0;

      for(int var7 = var0.length() - 1; var6 < var7; ++var6) {  
         var5 ^= var0.charAt(var6);                             # for each char in flag, var5 = var5 ^ char
         var1 = var1 + (char)(var4 ^ var5);                     # for each interation of loop, append (char)(var4 ^ var5)
      }

      return var1;
   }
```

So we have **enc = (char)(var1) + (char)(var1 ^ var5)**

And we can simply extract (char)(var1) which is just the first character of the encrypted flag.

If we xor **(char)(var1) with (char)(var1 ^ var5)** we will get var5. 

We can reverse var5 since we know what it is being xored with, and thus get the flag.

```py
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
```

![image](https://user-images.githubusercontent.com/76640319/115530657-8bf14000-a2c6-11eb-82e6-61fcf0269e82.png)

```
CTFSG{f8907165369e9629b3547df1bb4890d8}
```
