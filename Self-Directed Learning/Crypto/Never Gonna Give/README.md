# Never Gonna Give

---

### Challenge Description

> Steve and Dave use a One Time Pad to encrypt their conversations. Steve likes to talk about Rick Astley songs, Dave...likes to talk about flags.

> Concept(s) Required: One Time Pad, Properties of XOR

[nevergonnagive.zip](https://github.com/caprinux/Cyberthon-2021-Training/files/6369155/nevergonnagive.zip)

---

### Solution

If you google up a little on one time pad reuse vulnerability, you will realize that reusing the key is insecure.

This allows us to easily break the one time pads and obtain the plaintext [crib dragging](https://www.trustwave.com/en-us/resources/blogs/spiderlabs-blog/the-way-of-the-cryptologist/). 

However, it is rather troublesome for us to slide the text against each other to find the key, so we will just use a [tool by Spider Labs](https://github.com/SpiderLabs/cribdrag) to help us.

We first xor the two strings of the conversation together, and then we use the crib dragging tool.

![image](https://user-images.githubusercontent.com/76640319/115951758-162ee380-a515-11eb-97b5-fd8e7fdd6148.png)

First, we know that the flag is somewhere here, and our flag handle is **CTFSG{**.

If you use **CTFSG{** as a crib, you will find ``the ga`` at position 49. With an intelligent guess, we can figure out that it stands for ``the game``.

If we use **the game** as our crib, we find a partial flag.

![image](https://user-images.githubusercontent.com/76640319/115951820-673ed780-a515-11eb-980d-23f138fe9d81.png)

Now we are slightly stuck since we can't really figure out anything else.

Let's look back at the challenge description. We see a clear reference to Rick Astley and in the name, we see a reference to the famous rick roll song.

Could this be part of the lyrics of the song? ![image](https://user-images.githubusercontent.com/76640319/115951861-93f2ef00-a515-11eb-989e-a166511a337f.png)

Yes! Our partial plaintext is part of the lyrics. Let's try using the lyrics as a crib this time.

![image](https://user-images.githubusercontent.com/76640319/115951895-b6850800-a515-11eb-80de-ef1e6308c70d.png)

```
CTFSG{m4yb3_d0nt_r33us3_k3y5_0k}
```
