#!/usr/bin/env python3
from Registry import Registry
import re

def walk(reg, subkey, depth=0):
    key = reg.open("\\".join(subkey.path().split("\\")[1:]))
    
    for value in [v for v in key.values() if v.value_type() == Registry.RegSZ or v.value_type() == Registry.RegExpandSZ]:        
        if re.match(".*[-_=:]{1}[a-f0-9]{4}.*?", value.name()):
            print(value.name())
            print()
        
        if re.match(".*[-_=:]{1}[a-f0-9]{4}.*?", value.value()):
            print(value.value())
            print()
    
    for subkey in subkey.subkeys():
        walk(reg, subkey, depth + 1)

def main():
    reg = Registry.Registry("beyblade")
    walk(reg, reg.root())

if __name__ == "__main__":
    main()
