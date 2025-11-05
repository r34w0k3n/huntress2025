#!/usr/bin/env python3
import re

def main():
    data = [o.strip() for o in open("spaghetti").readlines()]

    for line in data:
        if "$MyOasis4" in line:
            bin = line.split('"')[1].replace("~", "0").replace("%", "1")
            bin = "".join([chr(int(bin[n:n+8], 2)) for n in range(0, len(bin), 8)])
            
            with open("MyOasis4.ps1", "w") as fout:
                fout.write(bin)
            
            break

    for line in data:
        if "$TDefo" in line:
            bin = line.split('"')[1].replace("~", "0").replace("%", "1")
            bin = "".join([chr(int(bin[n:n+8], 2)) for n in range(0, len(bin), 8)])
            
            with open("TDefo.ps1", "w") as fout:
                fout.write(bin)
                
            break
            
if __name__ == "__main__":
    main()
