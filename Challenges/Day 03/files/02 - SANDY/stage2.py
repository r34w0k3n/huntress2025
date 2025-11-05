#!/usr/bin/env python3
import base64

def main():
    code = [o.strip() for o in open("stage2.ps1").readlines()]
    data = []
    
    for line in code:
        if not line.startswith("$encoded"):
            continue

        data.append(base64.b64decode(line.split('"')[1]).replace(b"\x00", b"").decode())
        
    with open("stage3.ps1", "w") as fout:
        fout.write("\n".join(data))
    
if __name__ == "__main__":
    main()
