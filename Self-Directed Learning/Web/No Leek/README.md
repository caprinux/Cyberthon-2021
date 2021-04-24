# No Leek

---

### Challenge Description

> [Here](http://3qo9k5hk5cprtqvnlkvotlnj9d14b7mt.ctf.sg:50401/) is a really shoddily coded login page. Some people have tried hacking it and even managed to login. But the flag has yet to be found. Rumor has it that the flag lurks somewhere in the database. FYI: I heard the app uses sqlite.

> Note: please attempt this without using automated tools.

> Concept(s) Required: SQL Injection

---

### Solution

We are introduced with a login page as such:

![image](https://user-images.githubusercontent.com/76640319/115958762-50ab7700-a53b-11eb-9425-19cb3c494cfe.png)

If we try to login, with normal payloads like **admin'/** or **OR 1=1**, we will not get anything useful except for a hello message.

![image](https://user-images.githubusercontent.com/76640319/115958787-73d62680-a53b-11eb-9685-30613ba208c7.png)

Let's try to leak the columns.

First, we have to identify the number of columns there are. This can be done with a **UNION SELECT NULL, NULL, NULL, NULL ... --** and try with as many NULLS until you do not get an error message.

For this challenge, sending **UNION SELECT NULL, NULL** logged me in successfully so I know there are 2 columns.

Next, we want to find the name of the columns.

Since we know this website uses SQLITE, we can send a payload as such **' UNION SELECT NULL, sql FROM sqlite_master --**

This will present us with the following :

![image](https://user-images.githubusercontent.com/76640319/115958875-ecd57e00-a53b-11eb-9c5d-bf691e7e10cb.png)

As we can see, hiddenflag column looks rather interesting. Perhaps we could figure out whats there.

Let's go back to our login page.

We can look at what is in hidden flag using the payload **' UNION SELECT NULL, hiddenflag FROM users--**.

![image](https://user-images.githubusercontent.com/76640319/115958923-1c848600-a53c-11eb-9b89-57e0beab1a9e.png)

```
CTFSG{h3y_y0u_l33k_fl4g_0h_n03_ggwp}
```
