#!/usr/bin/env python3
import base64
from Crypto.Cipher import AES
from Crypto.Util.Padding import unpad

def main():
    flag = base64.b64decode(b"Wx6eETGXddnmCT4qZ7BxgRYpC+kdjjFzXxW+BM4HiI3GPaslpFBnpk9XplnaSxNg")
    iv = b"\x04\xC9\xE6\x53\x65\x56\x8D\x0F\x8A\x02\xF5\x26\xBA\x00\xFC\x5B"
    key = base64.b64decode(b"xck724QVNPrlVF7csPEgQdEM1NkO4Wp9gjX6ZXyTgl0=")

    cipher = AES.new(key, AES.MODE_CBC, iv=iv)
    
    print(unpad(cipher.decrypt(flag), AES.block_size).decode().strip())
   
if __name__ == "__main__":
    main()
