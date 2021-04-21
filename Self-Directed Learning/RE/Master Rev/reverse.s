 .global _start
_start:
.intel_syntax noprefix


main:
        push    rbp
        mov     rbp, rsp
        sub     rsp, 16 				# setting up the stack
        lea     rax, [rbp-10]
        mov     rsi, rax 				# specifies destination of input [rbp-10]
        mov     edi, %s					# specifies format string %s
        mov     eax, 0 # empty eax
        call    __isoc99_scanf 				# scans input based on rsi edi 
        lea     rax, [rbp-10] 				# load input into rax
        mov     rdi, rax 				# move our flag to rdi, set up for checkflag
        call    checkFlag 				# takes in rdi argument and checks
        test    eax, eax 
        je      .FailCheck:				# jumps if eax == 0
        mov     edi, "Correct flag"
        call    puts 					# prints string "Correct Flag"
.FailCheck:
        mov     eax, 0
        leave
        ret

	checkFlag:
        push    rbp					
        mov     rbp, rsp				# sets up the stack
        mov     QWORD PTR [rbp-72], rdi			# move our input into [rbp-72]
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
        mov     eax, DWORD PTR [rbp-4]			# load 0 into eax initially, then 1, 2, 3, 4
        cdqe						# 
        mov     eax, DWORD PTR [rbp-64+rax*4]		# load 2 into eax initially, then 5,6,3,4,1,8,0,7
        movsx   rdx, eax				# load 2 into rdx initially, then 5,6,3,4,1,8,0,7
        mov     rax, QWORD PTR [rbp-72]			# move our input into rax
        add     rax, rdx				# 
        movzx   eax, BYTE PTR [rax]			# move byte at ptr [rax] into eax
        movsx   eax, al					# take 8 bits of eax value
        lea     edx, [rax+3]				# load [rax+3] into edx
        mov     eax, DWORD PTR [rbp-4]			# move 0 then 1, 2, 3, 4 into eax
        cdqe
        movzx   eax, BYTE PTR [rbp-13+rax]		# move eax + 0 bytes into eax
        movsx   eax, al					# take last 8 bits of eax value
        cmp     edx, eax				# check byte of edx against eax
        je      .loop
        mov     eax, 0					# fails check
        jmp     .checker				# fails check


.loop:
        add     DWORD PTR [rbp-4], 1			# loop 8 times
.counter:
        cmp     DWORD PTR [rbp-4], 8 			# counter from 1 to 8
        jle     .L8					# jump while counter < 9 
        mov     eax, 1					# pass check
.check:
        pop     rbp					# goes back to main to print "Correct Flag!"
        ret
