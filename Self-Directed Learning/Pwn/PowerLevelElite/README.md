# Power Level Elite

---

### Challenge Description

> Since this is the first pwn challenge, let's start simple. Prove that you have an elite power level and i'll give you a shell on my system.

> To help you out, I have included a pwntools template for you. Feel free to use that as a starting point for your exploit script!

> Interact with the service at: `3qo9k5hk5cprtqvnlkvotlnj9d14b7mt.ctf.sg:30501`

[powerlevelelite.zip](https://github.com/caprinux/Cyberthon-2021-Training/files/6330450/powerlevelelite.zip)

---

### Analysis

![image](https://user-images.githubusercontent.com/76640319/115133306-c1cdc480-a039-11eb-8277-0f71f4a928c2.png)

Running the binary, we see that it takes in an input after `Power Up => ` and then after we key in an input `123`, it says we aren't elite enough.

Let's take a look at the source code.

We can see the following function

```c
    if (current_power == 3133731337) {
        puts("You are truly an elite!");
        shell();
    } else {
        puts("You aren't elite enough...");
    }
```

As you can see, if our power is 3133731337, we will win and obtain a shell.

Let's try that.

![image](https://user-images.githubusercontent.com/76640319/115133336-ee81dc00-a039-11eb-9503-cdc8ca85ef92.png)

It works!

Let's connect to the remote service.

![image](https://user-images.githubusercontent.com/76640319/115133354-1c672080-a03a-11eb-80d5-8b79d314153d.png)

```
CTFSG{why_st0p_4t_9000_wh3n_y0u_c4n_d0_3133731337}
```
