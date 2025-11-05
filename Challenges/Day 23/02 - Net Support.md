**Category**: Malware  
**Author**: Ben Folland

![](./files/02%20-%20Net%20Support/02%20-%20Net%20Support.png)

---

The challenge ZIP contained a UTF-encoded PowerShell script with a large byte array in the middle, which itself was another ZIP archive.

```Python
#!/usr/bin/env python3
import re

def main():
    data = open("netsupport", "r").read()
    data = re.findall(r"@\([0-9,]*\)", data)[0]
    data = data[2:-1]
    data = data.split(",")
    data = bytes([int(o) for o in data])

    with open("extracted.zip", "wb") as fout:
        fout.write(data)
        
if __name__ == "__main__":
    main()
```

The embedded ZIP file was mostly filled with junk. The flag could be found in the `CLIENT32.ini` file, base64 encoded.

```
$ unzip -p extracted.zip | grep -ai flag | head -1
Flag=ZmxhZ3tiNmU1NGQwYTBhNWYyMjkyNTg5YzM4NTJmMTkzMDg5MX0NCg==

$ echo ZmxhZ3tiNmU1NGQwYTBhNWYyMjkyNTg5YzM4NTJmMTkzMDg5MX0NCg== | base64 -d
flag{b6e54d0a0a5f2292589c3852f1930891}
```

Flag: **flag{b6e54d0a0a5f2292589c3852f1930891}**

---

**Files:**
- [extract.py](./files//02%20-%20Net%20Support/extract.py)
- [extracted.zip](./files//02%20-%20Net%20Support/extracted.zip)
- [netsupport.zip](./files//02%20-%20Net%20Support/netsupport.zip)