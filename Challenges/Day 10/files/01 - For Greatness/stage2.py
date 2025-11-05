#!/usr/bin/env python3
import base64

def main():
    data = open("stage2.php").read()
    
    for char in "\n\t ":
        data = data.replace(char, "")
    
    data = data.split(";")[5].split("'")[1]
    data = base64.b64decode(data)
    
    with open("stage3.php", "wb") as fout:
        fout.write(data)
    
if __name__ == "__main__":
    main()
