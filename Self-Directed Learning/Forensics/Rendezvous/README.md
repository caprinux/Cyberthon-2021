# Rendezvous

---

### Challenge Description

> The police managed to intercept a communication between two parties that have been known to participate in illegal activities. Based on the intelligence we've received from our informants on the ground, they are planning a face to face meeting for an illegal transaction. Are you able to help us identify where that meeting might take place?

> The flag for this challenge is the name of the location in lowercase characters. The following is the format for this flag: CTFSG{xxx_xxxxx_xxxx_xxxx}

> p.s. each 'x' corresponds to one character.

> Concept(s) Required: SMTP protocol

--- 

### Solution

We are provided with a pcap file again and it contains a bunch of SMTP and TCP protocols.

![image](https://user-images.githubusercontent.com/76640319/115980317-7c237580-a5be-11eb-95fd-7534d203b696.png)

Packet 17 immediately catches my eye: **Data Fragment, 14975 bytes**

Opening it, we see a bunch of base64 encoded data

![image](https://user-images.githubusercontent.com/76640319/115980344-a83ef680-a5be-11eb-8e74-9306ceff9b31.png)

We can copy this whole chunk of base64 encoded text and copy it into a text file.

Next we will write a short script to decode the text

```py
# coding: utf-8
enc = open('interception.txt', 'r').read()
import base64

decr = base64.b64decode(enc)
print(decr)

out = open('interception.png', 'wb')
out.write(decr)
out.close()
```

This will output our file into a png file. Opening it we see an image as such:

![image](https://user-images.githubusercontent.com/76640319/115980381-dd4b4900-a5be-11eb-8feb-13afb6abcda5.png)

By using TinEye reverse image search, we find the location

![image](https://user-images.githubusercontent.com/76640319/115980394-fb18ae00-a5be-11eb-9c57-4b7f4af080f0.png)

``` 
CTFSG{toa_payoh_town_park}
```
