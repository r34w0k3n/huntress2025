**Category**: Forensics  
**Author**: Soups71

![](./files/01%20-%20Bussing%20Around/01%20-%20Bussing%20Around.png)

---

The challenge ZIP contained a file named `bussing_around.pcapng`.

This challenge was deceptively simple. The packet capture contained a bunch of [Modbus](https://en.wikipedia.org/wiki/Modbus) traffic. There were multiple reads and writes to multiple registers, but only one of those registers mattered; register `0`. The writes could be directly interpreted as binary. That was it.

I wrote the following Python script to extract the binary stream:

```Python
#!/usr/bin/env python3
import pyshark

def main():
    capture = pyshark.FileCapture("bussing_around.pcapng")
    bits = ""

    for packet in capture:
        if "MODBUS" not in packet:
            continue
        
        if packet.ip.src != "172.20.10.6":
            continue
         
        if packet.modbus.func_code != "6":
            continue
         
        if packet.modbus.regnum16 == "0":
            bits += packet.modbus.regval_uint16
    
    with open("out.bin", "wb") as fout:
        for n in range(0, len(bits), 8):
            fout.write(int(bits[n:n+8], 2).to_bytes())

if __name__ == "__main__":
    main()
```

The resulting bytes turned out to be a ZIP archive:

```
$ python extract.py
$ file out.bin 
out.bin: Zip archive data, at least v1.0 to extract, compression method=store

$ unzip out.bin 
Archive:  out.bin
The password is 5939f3ec9d820f23df20948af09a5682 .
[out.bin] flag.txt password: 
 extracting: flag.txt
 
$ cat flag.txt  
flag{4d2a66c5ed8bb8cd4e4e1ab32c71f7a3}
```

Flag: **flag{4d2a66c5ed8bb8cd4e4e1ab32c71f7a3}**

---

**Files:**
- [bussing_around.pcapng](./files//01%20-%20Bussing%20Around/bussing_around.pcapng)
- [extract.py](./files//01%20-%20Bussing%20Around/extract.py)
- [flag.txt](./files//01%20-%20Bussing%20Around/flag.txt)
- [out.bin](./files//01%20-%20Bussing%20Around/out.bin)