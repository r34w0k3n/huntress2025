**Category**: Warmups  
**Author**: John Hammond

![](./files/02%20-%20Snooze/02%20-%20Snooze.png)

---

The challenge file named `snooze` was only 45 bytes. The Linux `file` command identified it as compressed data.

```
$ file snooze
snooze: compress'd data 16 bits

$ zcat snooze                       
flag{c1c07c90efa59876a97c44c2b175903e}
```

Flag: **flag{c1c07c90efa59876a97c44c2b175903e}**

---

**Files:**
- [snooze](./files//02%20-%20Snooze/snooze)