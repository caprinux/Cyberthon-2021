# Not So Silent

---

### Challenge Description

![image](https://user-images.githubusercontent.com/76640319/113474197-0b96a680-94a1-11eb-801c-f3ac7629ddda.png)

[noisy.zip](https://github.com/caprinux/Cyberthon-Training/files/6252262/noisy.zip)

---

### Solution

We are provided a pcapng file which can be opened with wireshark. Pcaps are basically data files that contains the packet data of a network.

Upon opening the file, we see a bunch of HTTP and TCP packets. Naturally we are always more interested in the HTTP packets as it could possibly contain valuable data.

Also scrolling through the wireshark file, we see LOTS of ![image](https://user-images.githubusercontent.com/76640319/113474375-44834b00-94a2-11eb-80e8-cd53b80b11c2.png), 401 http code indicates unauthorization. 

So we write a filter to find any packets that couldve possible been authorized, `http.response.code!=401`. What this does is that it filters through the http response codes to show anything that is not code 401.

If you key that in and enter it, you will find yourself looking at only one packet. 

![image](https://user-images.githubusercontent.com/76640319/113474510-f6227c00-94a2-11eb-9dff-eea040181b7d.png)

If you open this packet, and look at the hex code, you will see the following string appended. ![image](https://user-images.githubusercontent.com/76640319/113474530-118d8700-94a3-11eb-8f88-f9712b6604cc.png)

Alternatively, if you right click on the packet and Follow > HTTP Stream, you will see the appended string as well.

![image](https://user-images.githubusercontent.com/76640319/113474549-2d912880-94a3-11eb-92e7-3665457b78fc.png)

Now you know the format of the flag, and you know that you want to find the admin password. Since this packet has code 200, it means that it has succesfully authorized and the password is somewhere around this packet.

From here there are two ways to solve it.

Firstly, authorization is a packet sent by the server to the client, and naturally, the client has to send the form data to the server before that. Hence if we go to one packet before this authorization packet and you list everything, you will find this.

![image](https://user-images.githubusercontent.com/76640319/113474607-76e17800-94a3-11eb-8654-8947113c51ba.png)

Alternatively, from the page where you followed the HTTP stream, you will see a base64 authorization string

![image](https://user-images.githubusercontent.com/76640319/113474622-8e206580-94a3-11eb-9a00-0bea634bc260.png)

If you decode this with base64, you will obtain `admin:catherine`. Hence the flag is

```
CTFSG{catherine}
```
