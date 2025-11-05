**Category:** Warmups  
**Author:** John Hammond

![](./files/03%20-%20Spam%20Test/03%20-%20Spam%20Test.png)

---

Again, rather self-explanatory. The flag was the MD5 hash of the [Generic Test for Unsolicited Bulk Email](https://en.wikipedia.org/wiki/GTUBE) string.

```
XJS*C4JDBQADN1.NSBN3*2IDNEN*GTUBE-STANDARD-ANTI-UBE-TEST-EMAIL*C.34X
```

```
>>> import hashlib
>>> print("flag{%s}" % hashlib.md5(b"XJS*C4JDBQADN1.NSBN3*2IDNEN*GTUBE-STANDARD-ANTI-UBE-TEST-EMAIL*C.34X").hexdigest())
flag{6a684e1cdca03e6a436d182dd4069183}
```

Flag: **flag{6a684e1cdca03e6a436d182dd4069183}**
