# Number Game

---

### Challenge Description

> I've turned a number game I used to play in primary school into a reverse engineering problem. Can you reverse engineer the algorithm in the pyc file and figure out how to decrypt the flag?

> Concept(s) Required: Python, pyc format

---

### Solution

We are given a **.pyc** file. With some googling we are able to find a [tool](https://pypi.org/project/uncompyle6/), Uncompyle6, to decompile our pyc file so that it is readable.

After decompiling, we have our following python code. After adding some comments to the code, we have the following:

```py
from binascii import hexlify

def preprocess(data):
    return ''.join([str(x).zfill(3) for x in list(data)]) # adds 0s at the front of each char until its 3 chars long


def encode(data):
    y = list(data)            # converts input into a list
    x = y.pop(0)              # takes character at index 0
    w = 1 # w = 1
    v = ''
    while y:                  # while y is not empty, do the following: 
        z = y.pop(0)          # take character at index 0
        if x == z:            # if x = z,
            if w < 9:         # if w < 9
                w += 1        # w = w + 1
        else:
            v += f"{w}{x}"    # once done, string w and x together
            x = z             # set x = z
            w = 1             # reset w
        if not y:             # if y is empty, string w and x together
            v += f"{w}{x}"

    return v


with open('flag.txt', 'rb') as (f):
    flag = f.read()
d = preprocess(flag)
for i in range(24):           # encode this 24 times
    d = encode(d)

with open('flag.txt.encrypted', 'w') as (f):
    f.write(d)
```

If you are still stuck and do not understand what is going on, we can blackbox this encoding.

Modify the script such that it only encrypts data once. Let's give an input **"abc"**.

Our output after 1 round of encoding will be **"1019171019181029101110"**.

Let's think about what's going on in the background. First abc is converted into its ascii numbers, 

![image](https://user-images.githubusercontent.com/76640319/115515249-8809f180-a2b7-11eb-9774-6feff98bdc92.png)

Then it appends `0` to the front of these ascii numbers, turning it into **097098099**

It then counts each character and records the number of time it occurs. 

For example:

```
0133
will become
101123 # 1 occurence of 0, 1 occurence of 1, 2 occurence of 3. Hence 10 11 23
```

Hence if we encode **097098099** with our theory, we will get **10 19 17 10 19 18 10 29**, which is the same as our output from earlier!! _(the extra 10110 is just the new line)_

With this we can write our script to decode this.

```py
import re
enc = open('flag.txt.encrypted', 'r').read()
enc = list(str(enc))
plain = ''

for i in range(24):                   # decode 24 times
    while enc:                        # for each cycle while enc is not empty
        count = enc.pop(0)            # takes first integer into char
        char = enc.pop(0)             # takes second integer into count
        count = int(count)            
        plain += count * char         # repeats char count number of times and puts in plain
    enc = list(str(plain))            # puts plain back into enc for more decryption
    plain = ''                        # resets plain

decoded = ''.join(enc)                # list to string
flag = re.findall('...',decoded)      # split string into list of 3 chars each
for i in flag:
    i = int(i.lstrip('0'),10)         # convertelement to integer and remove any 0s at the start of the integer
    print(chr(i), end='')             # convert integer into ascii and concatenate them
```

```
CTFSG{pr1m4ry_sk00l_numb3r_g4m3}
```

