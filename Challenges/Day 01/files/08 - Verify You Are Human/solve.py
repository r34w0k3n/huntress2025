#!/usr/bin/env python
from Crypto.Util.number import long_to_bytes

def main():
    stack = [
        0x8484D893,
        0x97C6C390,
        0x929390C3,
        0xC7C3C490,
        0x939C939C,
        0xC6C69CC0,
        0x939CC697,
        0xC19DC794,
        0x9196C1DE,
        0xC2C4C9C3,
    ]

    flag = b""

    for item in stack:
        item = item ^ 0xA5A5A5A5
        flag += long_to_bytes(item)
        
    print(flag.decode()[-1::-1])

if __name__ == "__main__":
    main()
