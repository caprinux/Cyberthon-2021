# The Day

---

### Challenge Description

> Yes we're very generous. Once again, free flag for you over here! One catch though. You might have to wait quite a while before we decide to give it to you.

> Concept(s) Required: HTTP Cookies

---

### Solution

```py
from typing import Optional
from fastapi import FastAPI, Cookie


FLAG = open('/app/flag.txt', 'r').read().rstrip()

FAIL = {'flag': 'Come back on 12-12-4242 12:12:12 PM GMT+08:00'}
SUCCESS = {'flag': FLAG}

TARGET_TIME = 71727221532000

app = FastAPI(docs_url=None, redoc_url=None)


@app.get('/flag')
def flag(unix_time: Optional[int] = Cookie(None)):
    if not unix_time or unix_time != TARGET_TIME:
        return FAIL

    return SUCCESS
```

From the code, we can see that the webside has a **/flag** directory. 

It checks whether the time is **12-12-4242 12:12:12 PM GMT +08:00** based off the cookie UNIX value.

Hence if we modify the cookie into the appropriate UNIX vaue, we will get the flag.

We can convert the date and time to UNIX in cyberchef, and then navigate to /flag directory and change the unix_time cookie value to **71727221532000**

![image](https://user-images.githubusercontent.com/76640319/115958694-09bd8180-a53b-11eb-9a98-0409bd32e21f.png)

```
CTFSG{15_1t_truly_d_d4y_0r_15_1t_n0t}
```
