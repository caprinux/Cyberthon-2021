# Beepboop

---

### Challenge Description

> What the heck? This binary seems impossible to analyze statically (by just reading the disassembly). Is there another type of analysis that we can use?

> Hint 1: You don't need to deobfuscate anything
> Hint 2: No side-channel attacks required.

> Concept(s) Required: Executable Packing, Dynamic Analysis

---

### Solution

Run the binary:

![image](https://user-images.githubusercontent.com/76640319/115519864-2dbf5f80-a2bc-11eb-8dba-bd61af318922.png)

Hm interesting. We run checksec:

![image](https://user-images.githubusercontent.com/76640319/115519901-34e66d80-a2bc-11eb-8527-909e50b8799c.png)

Since it is packed with executables, we should unpack it.

![image](https://user-images.githubusercontent.com/76640319/115520026-4fb8e200-a2bc-11eb-9d11-13372188df62.png)

We now trace library calls to see what is going on in the background:

![image](https://user-images.githubusercontent.com/76640319/115520079-5cd5d100-a2bc-11eb-84d9-978623297b33.png)

Did you see it?

```
CTFSG{S1GN4L_B33P_B00P}
```

---

That was not the intended solution haha

Let's redo this in GDB.

![image](https://user-images.githubusercontent.com/76640319/115520192-7b3bcc80-a2bc-11eb-9b2d-7a743b55f4e7.png)

What the heck?? There are thousands of mov instructions. With some googling you will find that its obfuscated with movfuscation.

At first, I intended to install a de-movfuscator but while it was taking some time to install, I decided to run it and check it out.

As soon as I run it, I hit a SEGSEGV signal, which indicates Segmentation Fault.

![image](https://user-images.githubusercontent.com/76640319/115520389-ae7e5b80-a2bc-11eb-93ac-092e3640ab0b.png)

Okay... Let's look at the stack which stores data!! If there's any comparison going on, the variables will usually first be pushed onto the stack.

![image](https://user-images.githubusercontent.com/76640319/115520483-c9e96680-a2bc-11eb-9269-41e7ad1042a1.png)

Got it. 

```
CTFSG{S1GN4L_B33P_B00P}
```
