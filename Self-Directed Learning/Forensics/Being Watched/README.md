# Being Watched

---

### Challenge Description

> This employee was so careless that he didn't realize his traffic was being sniffed. Unfortunately for him, he downloaded the flag while being watched. Can you recover the flag from the captured traffic?

> Concept(s) Required: Packet analysis

> Useful Tool(s): Wireshark

---

### Solution

Opening the pcap file, we see a bunch of FTP and TCP protocols.

With some familiarity of such protocols, I immediately filter for FTP-Data, which leaves me with 2 packets.

![image](https://user-images.githubusercontent.com/76640319/115980136-ecc99280-a5bc-11eb-9fd3-a59727e2ca09.png)

Looking at the hexdump of the second packet, we notice the **PK** magic bytes which indicates a zip file.

We follow the stream of the FTP-Data packet and we extract it as raw data.

![image](https://user-images.githubusercontent.com/76640319/115980242-b3455700-a5bd-11eb-9e2a-5a3924c1ef1a.png)

We try to unzip the zip however it is password protected. 

Using john, we can easily brute force the zip:

![image](https://user-images.githubusercontent.com/76640319/115980253-d112bc00-a5bd-11eb-8cbc-651a8f61aec4.png)

With our password, we can unzip the zip and obtain our flag.

```
CTFSG{5N1FF_53CUR3_F1L35}
```
