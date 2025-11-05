#!/usr/bin/env python3
import base64

def main():
    code = [o.strip() for o in open("SANDY.au3", "rb").readlines()[521:1911]]
    data = ""
    
    for line in code:
        line = line.replace(b"\x00", b"").decode()
        data += line.split('"')[1]
        
    data = base64.b64decode(data).replace(b"\x00", b"").decode()
    
    with open("stage2.ps1", "w") as fout:
        fout.write(data)
    
if __name__ == "__main__":
    main()
