# Master Rev

_this is honestly the most fun training challenge_

---

### Challenge Description

> Now it's time to learn to read raw x64 assembly. Can you reverse engineer the attached program to figure out the correct input?

> Note: The flag format is CTFSG{correct input}

---

### Challenge Solution

```asm
.LC0:
        .string "%s"
.LC1:
        .string "Correct flag"
main:
        push    rbp
        mov     rbp, rsp
        sub     rsp, 16
        lea     rax, [rbp-10]
        mov     rsi, rax
        mov     edi, OFFSET FLAT:.LC0
        mov     eax, 0
        call    __isoc99_scanf
        lea     rax, [rbp-10]
        mov     rdi, rax
        call    checkFlag
        test    eax, eax
        je      .L2
        mov     edi, OFFSET FLAT:.LC1
        call    puts
.L2:
        mov     eax, 0
        leave
        ret
checkFlag:
        push    rbp
        mov     rbp, rsp
        mov     QWORD PTR [rbp-72], rdi
        movabs  rax, 3698143809343140973
        mov     QWORD PTR [rbp-13], rax
        mov     BYTE PTR [rbp-5], 118
        mov     DWORD PTR [rbp-64], 2
        mov     DWORD PTR [rbp-60], 5
        mov     DWORD PTR [rbp-56], 6
        mov     DWORD PTR [rbp-52], 3
        mov     DWORD PTR [rbp-48], 4
        mov     DWORD PTR [rbp-44], 1
        mov     DWORD PTR [rbp-40], 8
        mov     DWORD PTR [rbp-36], 0
        mov     DWORD PTR [rbp-32], 7
        mov     DWORD PTR [rbp-4], 0
        jmp     .L5
.L8:
        mov     eax, DWORD PTR [rbp-4]
        cdqe
        mov     eax, DWORD PTR [rbp-64+rax*4]
        movsx   rdx, eax
        mov     rax, QWORD PTR [rbp-72]
        add     rax, rdx
        movzx   eax, BYTE PTR [rax]
        movsx   eax, al
        lea     edx, [rax+3]
        mov     eax, DWORD PTR [rbp-4]
        cdqe
        movzx   eax, BYTE PTR [rbp-13+rax]
        movsx   eax, al
        cmp     edx, eax
        je      .L6
        mov     eax, 0
        jmp     .L9
.L6:
        add     DWORD PTR [rbp-4], 1
.L5:
        cmp     DWORD PTR [rbp-4], 8
        jle     .L8
        mov     eax, 1
.L9:
        pop     rbp
        ret
```

Looks intimidating right? Let's break it down a little.

Going through most part of the assembly, I noticed something odd. I saw a long integer `3698143809343140973` being stored into **rbp-13** and `118` being stored into **rbp-5**.

They looked like words to be waiting to be decoded 🤔. I tried to convert the long integer from long to bytes and the `118` into ascii.

![image](https://user-images.githubusercontent.com/76640319/115517606-e3d57a00-a2b9-11eb-8a13-d391eb2efe3e.png)

Doesn't this look a little familiar...

If you still haven't noticed, let me make it a little clearer for you.

![image](https://user-images.githubusercontent.com/76640319/115517777-15e6dc00-a2ba-11eb-84aa-85b028375e28.png)

That's clearly the name of our challenge! But we are far from done.

The code is clearly doing some funny business with our string here. Let's break it down.

```asm
 .global _start
_start:
.intel_syntax noprefix


main:
        push    rbp
        mov     rbp, rsp
        sub     rsp, 16 			              	# setting up the stack
        lea     rax, [rbp-10]
        mov     rsi, rax 			              	# specifies destination of input [rbp-10]
        mov     edi, %s					                # specifies format string %s
        mov     eax, 0 # empty eax
        call    __isoc99_scanf 				        # scans input based on rsi edi 
        lea     rax, [rbp-10] 				        # load input into rax
        mov     rdi, rax 				              # move our flag to rdi, set up for checkflag
        call    checkFlag 				            # takes in rdi argument and checks
        test    eax, eax 
        je      .FailCheck:				            # jumps if eax == 0
        mov     edi, "Correct flag"
        call    puts 					                # prints string "Correct Flag"
.FailCheck:
        mov     eax, 0
        leave
        ret

	checkFlag:
        push    rbp					
        mov     rbp, rsp				              # sets up the stack
        mov     QWORD PTR [rbp-72], rdi			  # move our input into [rbp-72]
        movabs  rax, 3698143809343140973		
        mov     QWORD PTR [rbp-13], rax			
        mov     BYTE PTR [rbp-5], 118			
        mov     DWORD PTR [rbp-64], 2				
        mov     DWORD PTR [rbp-60], 5			 
        mov     DWORD PTR [rbp-56], 6			
        mov     DWORD PTR [rbp-52], 3			
        mov     DWORD PTR [rbp-48], 4			
        mov     DWORD PTR [rbp-44], 1			
        mov     DWORD PTR [rbp-40], 8
        mov     DWORD PTR [rbp-36], 0
        mov     DWORD PTR [rbp-32], 7
        mov     DWORD PTR [rbp-4], 0
        jmp     .counter
.L8:
        mov     eax, DWORD PTR [rbp-4]		    	# load 0 into eax initially, then 1, 2, 3, 4
        cdqe						# 
        mov     eax, DWORD PTR [rbp-64+rax*4]		# load 2 into eax initially, then 5,6,3,4,1,8,0,7
        movsx   rdx, eax			                	# load 2 into rdx initially, then 5,6,3,4,1,8,0,7
        mov     rax, QWORD PTR [rbp-72]		    	# move our input into rax
        add     rax, rdx				# 
        movzx   eax, BYTE PTR [rax]		    	# move byte at ptr [rax] into eax
        movsx   eax, al				            	# take 8 bits of eax value
        lea     edx, [rax+3]			         	# load [rax+3] into edx
        mov     eax, DWORD PTR [rbp-4]			# move 0 then 1, 2, 3, 4 into eax
        cdqe
        movzx   eax, BYTE PTR [rbp-13+rax]	# move eax + 0 bytes into eax
        movsx   eax, al				            	# take last 8 bits of eax value
        cmp     edx, eax			            	# check byte of edx against eax
        je      .loop     
        mov     eax, 0					          # fails check
        jmp     .checker				          # fails check


.loop:
        add     DWORD PTR [rbp-4], 1			# loop 8 times
.counter:
        cmp     DWORD PTR [rbp-4], 8 			# counter from 1 to 8
        jle     .L8				               	# jump while counter < 9 
        mov     eax, 1					          # pass check
.check:
        pop     rbp					              # goes back to main to print "Correct Flag!"
        ret
```

Okay, it's a little long.

```asm
	checkFlag:
        push    rbp					
        mov     rbp, rsp				              # sets up the stack
        mov     QWORD PTR [rbp-72], rdi			  # move our input into [rbp-72]
        movabs  rax, 3698143809343140973		
        mov     QWORD PTR [rbp-13], rax			
        mov     BYTE PTR [rbp-5], 118			
        mov     DWORD PTR [rbp-64], 2				
        mov     DWORD PTR [rbp-60], 5			 
        mov     DWORD PTR [rbp-56], 6			
        mov     DWORD PTR [rbp-52], 3			
        mov     DWORD PTR [rbp-48], 4			
        mov     DWORD PTR [rbp-44], 1			
        mov     DWORD PTR [rbp-40], 8
        mov     DWORD PTR [rbp-36], 0
        mov     DWORD PTR [rbp-32], 7
        mov     DWORD PTR [rbp-4], 0
        jmp     .counter
```

This function sets up a lookup table by storing integers into the stack.

```asm
.L8:
        mov     eax, DWORD PTR [rbp-4]		    	# load 0 into eax initially, then 1, 2, 3, 4
        cdqe						# 
        mov     eax, DWORD PTR [rbp-64+rax*4]		# load 2 into eax initially, then 5,6,3,4,1,8,0,7
        movsx   rdx, eax			                	# load 2 into rdx initially, then 5,6,3,4,1,8,0,7
        mov     rax, QWORD PTR [rbp-72]		    	# move our input into rax
        add     rax, rdx				# 
        movzx   eax, BYTE PTR [rax]		    	# move byte at ptr [rax] into eax
        movsx   eax, al				            	# take 8 bits of eax value
        lea     edx, [rax+3]			         	# load [rax+3] into edx
        mov     eax, DWORD PTR [rbp-4]			# move 0 then 1, 2, 3, 4 into eax
        cdqe
        movzx   eax, BYTE PTR [rbp-13+rax]	# move eax + 0 bytes into eax
        movsx   eax, al				            	# take last 8 bits of eax value
        cmp     edx, eax			            	# check byte of edx against eax
        je      .loop     
        mov     eax, 0					          # fails check
        jmp     .checker				          # fails check
```

This refers to our look up table and then it looks at bytes at different indexes.

So as a whole, the program takes in an input of 8 bytes, and then it checks it with a loop that iterates through each byte of the 8 bytes for each loop, based on the different indexes in the lookup table.

It moves the byte pointer which is compared to the input by 2, 5, 6, 3, 4, 1, 8, 0, 7 index and compared against **m45t3rR3v**.

Hence if we were to shift our string around, **3rmt345vR** will give **m45t3rR3v** when compared at the specified indexes.

However, that's not all.

```asm
        movsx   eax, al				            	# take 8 bits of eax value
        lea     edx, [rax+3]			         	# load [rax+3] into edx
```

A value **3** is also being added to our input before it is checked. Hence if we take our **3rmt345vR** and minus 3 from each character, we get

![image](https://user-images.githubusercontent.com/76640319/115519007-63b01400-a2bb-11eb-93fe-fb94321147f5.png)

Enclosing this into the flag wrapped gives us our final flag.

```
CTFSG{0ojq012sO}
```
