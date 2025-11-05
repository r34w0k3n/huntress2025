#!/usr/bin/env python3
import re
import base64
import zlib

def main():
    data = open("j.php").read()
    data = data.split('$FRczk = "')[1].split('"')[0]
    data = data.encode("utf-8").decode("unicode_escape")
    data = base64.b64decode(data)
    data = zlib.decompress(data)
    
    with open("stage2.php", "wb") as fout:
        fout.write(data)
    
if __name__ == "__main__":
    main()
