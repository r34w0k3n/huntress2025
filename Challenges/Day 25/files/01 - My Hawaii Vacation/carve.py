#!/usr/bin/env python3
import struct

def main():
    data = open("Booking - ID Verification.exe", "rb").read()
    tail = data[-16:]

    offset = struct.unpack("<I", tail[8:12])[0]
    length = struct.unpack("<I", tail[12:])[0]

    print("offset = %08x" % offset)
    print("length = %08x" % length)

    lua = data[offset:offset+length]

    with open("sample.bin", "wb") as fout:
        fout.write(lua)

if __name__ == "__main__":
    main()
