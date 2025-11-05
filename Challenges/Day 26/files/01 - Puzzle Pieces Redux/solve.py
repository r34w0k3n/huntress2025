#!/usr/bin/env python3
import glob
import hashlib

def main():
    bins = []

    for item in glob.glob("*.bin"):
        checksum = hashlib.sha256(open(item, "rb").read()).hexdigest()
        
        if checksum[-1] != "0":
            continue
            
        bins.append([checksum[-1::-1], item])
        
    flag = []
        
    for item in sorted(bins):
        data = open(item[1], "rb").read()
        data = data[0x189B0:0x189B8]
        flag.append(data.decode().split("\n")[0])
        
    print("".join(flag[-1::-1]))

if __name__ == "__main__":
    main()
