#!/usr/bin/env python3
import glob
import struct

def main():
    files = glob.glob("$I*.txt")

    test = []

    for item in files:
        data = open(item, "rb").read()
        data = struct.unpack("<QQQL", data[:28])
        test.append([data[2], data[1]])
        
    test = list(sorted(test))
    flag = ""

    for n in range(0, len(test), 3):
        flag += chr(test[n][1])
        
    print(flag.strip())

if __name__ == "__main__":
    main()
