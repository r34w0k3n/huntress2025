#!/usr/bin/env python3
import re
import base64
from Crypto.Cipher import AES

def main():
    data = open("telestealer").read()

    parts = re.findall(r"parts.push\('(.+?)'\)", data)
    parts = "".join(parts)
    parts = base64.b64decode(parts).decode()

    with open("stage2.ps1", "w") as fout:
        fout.write(parts)

    parts = re.findall(r"FromBase64String\('(.+?)'\)", parts)
    key, iv, ct = parts

    key = base64.b64decode(key)
    iv = base64.b64decode(iv)
    ct = base64.b64decode(ct)

    decryptor = AES.new(mode=AES.MODE_CBC, key=key, iv=iv)
    pt = decryptor.decrypt(ct)

    with open("telestealer.exe", "wb") as fout:
        fout.write(pt)
        
if __name__ == "__main__":
    main()
