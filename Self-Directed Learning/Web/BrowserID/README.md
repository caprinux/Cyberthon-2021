# BrowserID

---

### Challenge Description

> Check out this app I made! It can tell you what browser you're using at the moment. How cool is that?

> Note: flag.txt is located in /app/flag.txt

> Concept(s) Required: SSTI

---

### Solution

**This [article](https://medium.com/@nyomanpradipta120/ssti-in-flask-jinja2-20b068fdaeee) was a great deal of help in solving this challenge.**

Since the website is printing our user-agent, perhaps it could be vulnerable to SSTI.

We try our theory by setting our user-agent as a simple payload **{{ 7 * 7 }}**.

![image](https://user-images.githubusercontent.com/76640319/115980789-f73a5b00-a5c1-11eb-81a8-ddb11d8a7b20.png)

Bingo! 

However, the hard part is finding the correct payload to send. If you attempt to send stuff like **{{ config }}** you will get an error as it is probably blocked.

Referring back to the article earlier, 

> We can see the previously discussed tuple being returned to us. Since we want to go back to the root object class, we’ll leverage an index of 1 to select the class type object. Now that we’re at the root object, we can leverage the __subclasses__ attribute to dump all of the classes used in the application. Inject {{ ‘’.__class__.__mro__[1].__subclasses__() }} into the SSTI vulnerability.

We send in the payload to dump all the classes used in the application.

![image](https://user-images.githubusercontent.com/76640319/115980830-48e2e580-a5c2-11eb-9b5e-eca2703e193e.png)

We get a huge chunk of classes as shown above. We look for the subprocess. Popen class and with some RNG, we find the correct index and slice it nicely to give us only the Popen class.

![image](https://user-images.githubusercontent.com/76640319/115980907-cdcdff00-a5c2-11eb-9262-50a095882597.png)

Now we have remote code execution!! We can just key in any commands following our Popen class.

![image](https://user-images.githubusercontent.com/76640319/115980938-f655f900-a5c2-11eb-83fe-d43dc9c179dc.png)

As you can see listing the directory, we see flag.txt in the directory. Let's concatenate it with cat.

![image](https://user-images.githubusercontent.com/76640319/115980952-08d03280-a5c3-11eb-9dfb-be7632096924.png)

```
CTFSG{t0x1c_br0ws3r_n4m3_15_d4ng3r0us}
```
