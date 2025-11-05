#!/usr/bin/env python3
import re

def main():
    data = open("netsupport", "r").read()
    data = re.findall(r"@\([0-9,]*\)", data)[0]
    data = data[2:-1]
    data = data.split(",")
    data = bytes([int(o) for o in data])

    with open("output.zip", "wb") as fout:
        fout.write(data)
        
if __name__ == "__main__":
    main()
