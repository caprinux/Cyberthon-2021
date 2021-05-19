# Market Research
---

### Description 

> Well, we have to admit that APOCALYPSE is pulling some "big brain" moves here. They seem to be conducting a survey to do a "Market Research" of everyone's favourite CTF categories so that they can write more malware which makes use of techniques in domains that fewer people are proficient at. Could you figure out if their survey website has any vulnerabilities?
> 
> Note: flag.txt is in the same directory as the webapp
> 
> _attached: app.py_

---

### Walkthrough 

```py
import os
import json
from flask import Flask, request

app = Flask(__name__)

votes = {
    "pwn": 0,
    "web": 0,
    "crypto": 0,
    "forensics": 0,
    "rev": 0,
    "misc": 0
}

@app.route('/')
def index():
    return app.send_static_file("index.html")

@app.route('/votes')
def get_votes():
    return json.dumps(votes)

@app.route('/vote')
def vote():
    choice = request.args.get("choice")
    votes[choice] += 1
    return json.dumps(votes)

if __name__ == '__main__':
    app.run(debug=True, host="0.0.0.0", port=8080)
```

As shown from the flask script, there are 2 subdirectories that we can go to. **/vote** and **/votes**.

Going to /votes, we see a json list of the category and its respective votes. 

```
{"web": 704, "misc": 10768, "rev": 617, "crypto": 1362, "forensics": 536, "pwn": 2140}
```

This honestly does not seem interesting to us so let's visit the other subdirectory.

![image](https://user-images.githubusercontent.com/76640319/117539931-532fc580-b03f-11eb-9eba-53af3bc27f1c.png)

Wowowow. What's this? A page of errors? Tbh I almost overlooked this and immediately closed the tab but coming back to it, I find more interesting stuff at the bottom of the webpage.

![image](https://user-images.githubusercontent.com/76640319/117539956-735f8480-b03f-11eb-8a7a-1d54da2f8cd0.png)

> **For code execution mouse-over the frame you want to debug and click on the console icon on the right side.**

W- What? Code INJECTION? ohmaigawd!

![image](https://user-images.githubusercontent.com/76640319/117539993-a43fb980-b03f-11eb-8583-4e0b1609fb38.png)

Trying a bunch of bash commands on the console throws me lots of errors. However on second thought, flask is a python module and naturally it should be a python console.

With that, we easily print our flag.

![image](https://user-images.githubusercontent.com/76640319/117540018-c46f7880-b03f-11eb-9c6d-99e9a3556382.png)

```
Cyberthon{y_d1d_w3_turn_0n_d3bug_m0d3_1n_pr0duct10n}
```
