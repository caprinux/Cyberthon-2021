# Prove Your Worth

---

### Challenge Description

> Okay, prove your worth as a reverse engineer by reversing all three levels. The binary given to you contains a placeholder flag. You should send your input to our network service for the actual flag.

> Interact with the service at: 3qo9k5hk5cprtqvnlkvotlnj9d14b7mt.ctf.sg:40101

> Hint 1: I highly recommend using pwntools to send your input
> Hint 2: Mind your input for level 2 :)

> Concept(s) Required: x64 Assembly

> Useful tools: ~~Ghidra~~, IDA


---

### Solution

Okay. I totally do NOT recommend Ghidra for this. Ghidra decompilation has let me down. Please get IDA Pro one way or another. _(i mean you can still use Ghidra, at most just shortens your lifespan a little for this challenge)_

Anyways, running the binary, we see that it takes in 5 inputs and terminates.

![image](https://user-images.githubusercontent.com/76640319/115521166-79263d80-a2bd-11eb-8557-f742746ec0a8.png)

Let's decompile this in IDA.

```c
int __cdecl main(int argc, const char **argv, const char **envp)
{
  setup_IO(argc, argv, envp);
  if ( (unsigned __int8)levelone() != 1 )
    return 0;
  if ( (unsigned __int8)leveltwo() != 1 )
    return 0;
  if ( (unsigned __int8)levelthree() == 1 )
  {
    puts("CTFSG{XXXXXXXXXXXXXXXXXXXXX}");
    fflush(stdout);
  }
  return 0;
}
```

Our program calls mains, which then calls levelone -> leveltwo -> levelthree -> print flag. 

```c
  puts("====================================================================");
  puts("                          LEVEL 01                                  ");
  puts("====================================================================");
  printf("=> ");
  fflush(stdout);
  for ( i = 1; i <= 5; ++i )
    __isoc99_scanf("%d", &v5[i]);
  fflush(stdin);
  v5[0] = 42;
  
  for ( j = 0; j <= 5; ++j )
  {
    for ( k = 0; k <= 5; ++k )
    {
      if ( j != k && v5[j] == v5[k] )
        return 0LL;
    }
  }
  
  for ( l = 2; l <= 5; ++l )
  {
    if ( v5[l] != v5[l - 1] + v5[l - 2] )
      return 0LL;
  }
  return 1LL;
}
```

For level 1, it takes in 5 inputs and puts them in **v5[1-5]**. It then sets **v5[0]=42**.

```c
  for ( j = 0; j <= 5; ++j )
  {
    for ( k = 0; k <= 5; ++k )
    {
      if ( j != k && v5[j] == v5[k] )
        return 0LL;
    }
  }
```

Next, it goes through some checks with j and k which is honestly seemingly useless. Let's skip this.

```c
  for ( l = 2; l <= 5; ++l )
  {
    if ( v5[l] != v5[l - 1] + v5[l - 2] )
      return 0LL;
  }
  return 1LL;
}
```

For this last function, it checks that the integer at the previous 2 index in **v5** adds to give the integer at the next index.

For example: It checks that **v5[0] + v5[1] == v5[2]**.

That's simple. We know that **v5[0] = 42** so we can just fill the rest up.

![image](https://user-images.githubusercontent.com/76640319/115522027-5183a500-a2be-11eb-8a1b-c4240be7f1f5.png)

What the heck?? I haven't even inputed anything in level 2 and it kicks me out.

Let's look at level 2 decompilation.

```c
 v2[0] = 103;
  v2[1] = 34;
  v2[2] = 105;
  v2[3] = 109;
  v2[4] = 121;
  v2[5] = 97;
  v2[6] = 37;
  v2[7] = 110;
  v2[8] = 111;
  v2[9] = 110;
  v2[10] = 96;
  v2[11] = 96;
  v2[12] = 122;
  v2[13] = 120;
  v3[0] = 73;
  v3[1] = -16;
  v3[2] = -104;
  v3[3] = 49;
  v3[4] = -44;
  v3[5] = -27;
  v3[6] = -80;
  v3[7] = 29;
  v3[8] = -97;
  v3[9] = -18;
  v3[10] = -76;
  v3[11] = -95;
  v3[12] = 105;
  v3[13] = -61;
  puts("====================================================================");
  puts("                          LEVEL 02                                  ");
  puts("====================================================================");
  printf("=> ");
  fflush(stdout);
  __isoc99_scanf("%14[^\n]s", v4);
  for ( i = 0; i <= 13; ++i )
  {
    if ( ((unsigned __int8)v4[i] ^ v2[i]) >> 4 || (((unsigned __int8)v4[i] ^ (unsigned __int8)v3[i]) & 0xF) != 0 )
      return 0LL;
  }
  return 1LL;
}
```

It sets up a lookup table with v2 and v3. 

It then scans in an input with ` __isoc99_scanf("%14[^\n]s", v4);`. What this does is that it scans in input and terminates at a newline.

So what could have possibly happened was that when we pressed enter after our last input in **level one**, we made a **\n** character which terminated level two.

Let's do this with pwntools.

![image](https://user-images.githubusercontent.com/76640319/115522629-dc649f80-a2be-11eb-8630-2555498ca28d.png)

Hm okay, we have ourselves seems like we can just send our input before the **level two** ascii art pops out.

Let's continue reading through **level two** decompilation.

```c
  for ( i = 0; i <= 13; ++i )
  {
    if ( ((unsigned __int8)v4[i] ^ v2[i]) >> 4 || (((unsigned __int8)v4[i] ^ (unsigned __int8)v3[i]) & 0xF) != 0 )
      return 0LL;
  }
  return 1LL;
}
```

What this does is that, if `unsigned __int8)v4[i] ^ v2[i]) >> 4` OR `(((unsigned __int8)v4[i] ^ (unsigned __int8)v3[i]) & 0xF) != 0` is true, it will return 0. Which is not what we want.

So we have to make both boolean false. Which means the value on both side MUST be equals to 0.

Let's look at them one by one.

```c
(v4[i] ^ v2[i]) >> 4 
```

What this does is that it xors **v4[i]** with **v2[i]** and then shifts the bits right by 4. Which means it only checks the first 4 bits. 

Remember the property of XOR: `` a ^ a = 0 ``. For this to be false, the first 4 bits of our input has to be equals to the first 4 bits of **v2[i]**.

Let's look at the next check.

```c
(v4[i] ^ v3[i]) & 0xF != 0
```

What this does is that it xors **v4[i] with v3[i]** and and only takes the last 4 bits of the result.

Our first check checks that the first 4 bits of our input is the same as the first 4 bits in **v2[i]**. 

Our second check checks that the last 4 bits of our input is the same as the last 4 bits in **v3[i]**.

So if we join the first 4 bits and the last 4 bits of each index of **v3[i] and v4[i]**. We have our answer.

![image](https://user-images.githubusercontent.com/76640319/115525615-d7551f80-a2c1-11eb-888b-46c92a541669.png)

Yes nik i hate mondays too 😭

Anyways, we have our answer for the second level. 

Let's try it out.

![image](https://user-images.githubusercontent.com/76640319/115526210-62ceb080-a2c2-11eb-8876-bc207593e852.png)

Success! Let's move on.

```c
{
  for ( i = 0; i <= 4; ++i )
    *(&v3 + 2 * i) = rand() & 0xF;
  puts("====================================================================");
  puts("                          LEVEL 03                                  ");
  puts("====================================================================");
  printf("=> ");
  fflush(stdout);
  __isoc99_scanf("%d %d %d %d %d", v8, &v7, &v6, &v5, v4);
  for ( j = 0; j <= 4; ++j )
  {
    if ( (((unsigned __int8)v4[2 * j] + (unsigned __int8)*(&v3 + 2 * j)) & 0xF) != 15 )
      return 0LL;
  }
  return 1LL;
}
```

First, we have a random(?) number being masked with 0xF. This means for`` i in range(4)``, ``*(&v3 + 2 * i)`` will be a random(?) number from 0-15.

Then our programs takes in 5 inputs and checks 

```c
(v4[2 * j] + *(&v3 + 2 * j)) & 0xF != 15
```

With some smart guesses, we can probably guess that v4 v5 v6 v7 v8 are all actually just indexes of **v4**. So we are in control of v4 here and we do not know what random(?) value `*(&v3 + 2 * j)` holds.

However everything is masked with 0xF. How do we get 15 if we do not know the what `*(&v3 + 2 * j)` holds??

With some [googling](https://stackoverflow.com/questions/14849866/c-rand-is-not-really-random), we can figure out that **rand() is actually not random**. It is pseudo-random. Means that we can recreate rand() if we know the seed.

In this case, we do not see any specification of **srand**. Which means it's probably just **default = 1**. 

Let's write a short C program to recreate these **rand() numbers**.

```c
#include <stdlib.h>
#include <stdio.h>

int main()
{
  int i;
  int lol;
  for ( i = 0; i <= 4; ++i ) { 
    lol = rand() & 0xF;
    printf("%d\n", lol);
  }
}
```

We compile our program with `gcc rand.c -o rand.elf`.

Let's run and look at our rand.elf.

![image](https://user-images.githubusercontent.com/76640319/115527232-775f7880-a2c3-11eb-8c1c-36441bc65edc.png)

Do you notice how even though I run it multiple times, the **rand()** value doesn't change? 

Now that we know our `*(&v3 + 2 * j)`, we can simplify the equation and easily solve level three.

We can rewrite our equation as such:

```c
v4 + (values in rand.elf) = 15
```

So let's finish our script and fire this bad boy.

```py
from pwn import *
p = remote('3qo9k5hk5cprtqvnlkvotlnj9d14b7mt.ctf.sg', 40101)

p.send('10 52 62 114 176')  # levelone
log.info("LEVEL 2")

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
```

![image](https://user-images.githubusercontent.com/76640319/115527851-09678100-a2c4-11eb-9532-f4fabd6c4ebc.png)


```
CTFSG{5n34ky_m45t3r_3ng1n33r}
```
