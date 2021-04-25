# Recollections

---

### Challenge Description 

> I was typing something in notepad when my computer crashed. But fortunately, I have a memory dump. Can you help me to recover it?

> Concept(s) Required: Memory analysis

> Useful Tool(s): Volatility
 
---

### Challenge Solution

We are provided with a memory dump. Since challenge hints at notepad, let's dump the process tree to find the pid of notepad.exe.

![image](https://user-images.githubusercontent.com/76640319/115980446-63678f80-a5bf-11eb-98d6-94f40064d819.png)

Next, now that we know the process id of notepad, we can dump the memory.

![image](https://user-images.githubusercontent.com/76640319/115980497-cbb67100-a5bf-11eb-83b0-7296e940cbe5.png)

It takes awhile but after some time, the dump is done. 

Next, we search for the flag in notepad.exe. Do note that data is stored in little endian form so you have to specify it in your search.

![image](https://user-images.githubusercontent.com/76640319/115980519-f7395b80-a5bf-11eb-9cc4-61875e6a0c93.png)

```
CTFSG{p33k1ng_1nt0_my_m3m0ry_y1k35}
```
