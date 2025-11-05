**Category**: Forensics  
**Author**: John Hammond

![](./files/01%20-%20Trashcan/01%20-%20Trashcan.png)

---

The challenge ZIP contained 195 text files in Windows Recycle Bin `$I` and `$R` format. The `$R` files (where deleted data is normally stored) were all the same, containing the string `When did I throw this out!?!?`.  That seemingly left nothing but the `$I` files. A quick Google search led me to [this article](https://medium.com/@thismanera/windows-recycle-bin-forensics-a2998c9a4d3e) about their structure. It quickly became apparent that each `$I` file had a different `File Size` field, with the values all falling within ASCII range. So I extracted these and ordered them based on their corresponding timestamps. This gave me an almost-flag that looked like this:

```
ffflllaaaggg{{{111ddd222bbb222bbb000555666777111eeeddd111eeeeee555888111222666777888888555000ddd555eee333222999}}}
```

Each character occurred exactly three times. I don't know why.

```Python
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
```

```
$ python solve.py
flag{1d2b2b05671ed1ee5812678850d5e329}
```

Flag: **flag{1d2b2b05671ed1ee5812678850d5e329}**

---

**Files:**
- [solve.py](./files//01%20-%20Trashcan/solve.py)
- [trashcan.zip](./files//01%20-%20Trashcan/trashcan.zip)