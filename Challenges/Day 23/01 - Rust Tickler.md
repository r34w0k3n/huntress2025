**Category:** Reversing  
**Author:** Nordgaren

![](./files/01%20-%20Rust%20Tickler/01%20-%20Rust%20Tickler.png)

---

This challenge was deceptively easy, which was on purpose. No reverse engineering was really required.

```
$ strings rust_tickler
...
7=06*gagg30d03gf2`f5g5dba3c0hhcd2c`4b,
```

I tested the above string with a bit of XOR decoding using `flag` as the key and that was that:

```
>>> flag="7=06*gagg30d03gf2`f5g5dba3c0hhcd2c`4b,"
>>> ord(flag[0])^ord("f"), ord(flag[1])^ord("l"), ord(flag[2])^ord("a"), ord(flag[3])^ord("g")
(81, 81, 81, 81)
>>> print("".join([chr(ord(o)^81) for o in flag]))
flag{6066ba5ab67c17d6d530b2a9925c21e3}
```

Flag: **flag{6066ba5ab67c17d6d530b2a9925c21e3}**

---

**Files:**
- [rust_tickler](./files//01%20-%20Rust%20Tickler/rust_tickler)