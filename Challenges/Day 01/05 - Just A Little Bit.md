**Category:** Warmups  
**Author:** John Hammond

![](./files/05%20-%20Just%20A%20Little%20Bit/05%20-%20Just%20A%20Little%20Bit.png)

---

This was just binary, but each octet was missing the first bit.

```
>>> flag="".join(flag.split())
>>> print("".join([chr(int(flag[n:n+7], 2)) for n in range(0, len(flag), 7)]))
flag{2c33c169aebdf2ee31e3895d5966d93f}
```

Flag: **flag{2c33c169aebdf2ee31e3895d5966d93f}**
