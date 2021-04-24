# Flag Poster

---

### Challenge Description

> Free flag for you over [here](http://3qo9k5hk5cprtqvnlkvotlnj9d14b7mt.ctf.sg:50301/flag)! Just make sure you request for it via post yeah?

> Concept(s) Required: HTTP POST, HTTP Headers

---

### Solution

Upon going to the website, we see the following string.

![image](https://user-images.githubusercontent.com/76640319/115958352-b26ae180-a539-11eb-8727-3ac2f953d3db.png)

```py
from typing import Optional
from fastapi import FastAPI, Request
from pydantic import BaseModel


SECRET = 'I know how to make a POST request'
FLAG = open('flag.txt', 'r').read().rstrip()

FAIL = {'Flag': 'Sorry no flag for you!'}
SUCCESS = {'Flag': FLAG}

app = FastAPI(docs_url=None, redoc_url=None)


class FlagRequest(BaseModel):
    secret: str


@app.post('/flag')
def flag(request: Request, flag_request: Optional[FlagRequest] = None):
    give_flag_header = request.headers.get('Give-Flag')

    if not give_flag_header or give_flag_header != 'yes':
        return FAIL

    if not flag_request or flag_request.secret != SECRET:
        return FAIL

    return SUCCESS
```

Reading the script, we see that it takes in a flag header **Give-Flag** with argument **yes**.

It also takes in a value **secret** with argument **I know how to make a POST request**.

Hence we connect to the service and provide the required arguments. _p.s. data should be sent in json_

```sh
http -v POST http://3qo9k5hk5cprtqvnlkvotlnj9d14b7mt.ctf.sg:50301/flag 'Give-Flag: yes' 'secret=I know how to make a POST request'
```

![image](https://user-images.githubusercontent.com/76640319/115958398-f231c900-a539-11eb-98fe-5411ba290b1e.png)

This also works with curl.

![image](https://user-images.githubusercontent.com/76640319/115958411-ffe74e80-a539-11eb-8cca-0b126938617c.png)

```
CTFSG{53r14l_fl4g_p05t3r_g1v35_fr33_fl4g5}
```
