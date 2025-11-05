#!/usr/bin/env python3
import binascii

def main():
    ct = binascii.unhexlify(b"28050C47124B155C09121755094B4208555A4558445745775D54445C4513595B47425E59165D")
    key = b"Nim is not for malware!"

    flag = ""

    for n in range(len(ct)):
        flag += chr(ct[n] ^ key[n% len(key)])

    print(flag)

if __name__ == "__main__":
    main()
