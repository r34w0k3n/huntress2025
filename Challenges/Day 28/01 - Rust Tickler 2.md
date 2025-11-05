**Category**: Reverse Engineering  
**Author**: Nordgaren

![](./files/01%20-%20Rust%20Tickler%202/01%20-%20Rust%20Tickler%202.png)

---

The challenge ZIP contained an x64 Windows binary named `rust-tickler-2.exe`. As usual with Rust, `main` wasn't *actually* the main function:

```C
int __fastcall main(int argc, const char **argv, const char **envp)
{
  __int64 (__fastcall *v4)(); // [rsp+30h] [rbp-8h] BYREF

  v4 = sub_140001350;
  return sub_140007920(&v4, &unk_14001C3F0);
}
```

The main function was located at `sub_140001350`. The binary asked for the name of the author's favorite cat.

![](./files/01%20-%20Rust%20Tickler%202/01.png)

Looking at the binary, it was clear that there were string decryption shenanigans going on, as both the question and response string were only present in memory for a brief moment. After a bit of static analysis I determined that setting a breakpoint at `0x1400043D8` would allow me view those strings in memory (the RDX register will point to them) just after decryption. Working backwards from that point, I was able to determine that the function responsible for setting up the decryption of those strings was called from `0x140003E56`:

![](./files/01%20-%20Rust%20Tickler%202/02.png)

Examining the memory pointed to by the RCX register when a breakpoint set on this location was hit, I saw memory like this:

```C
22D835EEA48 | 17 00 00 00 00 00 00 00
22D835EEA50 | 90 6D 5E 83 2D 02 00 00
22D835EEA58 | 17 00 00 00 00 00 00 00
22D835EEA60 | A8 1D C7 C4 0D F0 AD BA
22D835EAA68 | AA AA AA AA 0D F0 AD BA
```

Note the `0xBADF00D` filler bytes/markers. This structure represented an encrypted string in memory. The first and third fields denoted the length of the string, while the third field was a pointer to the encrypted value. The fourth field was a seed used in the decryption algorithm. The fifth field was the string's ID.

From here it was possible to go through and dump every encrypted string and then emulate the decryption process in Python, which is what my teammate Urck did. I decided that I wanted to do it a bit more dynamically, however. Browsing around the memory region used for the first string, I found this entry:

```C
22D835EE9A8 | 26 00 00 00 00 00 00 00
22D835EE9B0 | 90 69 5E 83 2D 02 00 00
22D8E5EE9B8 | 26 00 00 00 00 00 00 00
22D8E5EE9C0 | 7A B1 F8 17 0D F0 AD BA
22D8E5EE9C8 | 7F 00 00 00 0D F0 AD BA
```

This stuck out to me because I was looking for a flag that was 38 bytes (`0x26`) long. The binary was still suspended at my initial breakpoint, so I decided to see if simply swapping RCX's value from `0x22D835EEA48` to `0x22D835EE9A8` would do the trick. I did so and resumed execution.

Then my second breakpoint got hit with an RDX value of `0x22D835E7E70` and the memory looked like this:

```C
22D835E7E70 | 66 6C 61 67 7B 66 35 39
22D835E7E78 | 61 35 66 36 30 34 64 32
22D835E7E80 | 33 36 34 32 35 34 39 30
22D835E7E88 | 31 33 33 63 33 66 61 63
22D835E7E90 | 38 39 61 38 38 7D AB AB
22D835E7E98 | AB AB AB AB AB AB AB AB
22D835E7EA0 | AB AB AB AB AB AB EE FE
22D835E7EA8 | EE FE EE FE EE FE EE FE
22D835E7EB0 | 00 00 00 00 00 00 00 00
```

![](./files/01%20-%20Rust%20Tickler%202/03.png)

Flag: **flag{f59a5f604d236425490133c3fac89a88}**

---

**Files:**
- [rust-tickler-2.7z](./files//01%20-%20Rust%20Tickler%202/rust-tickler-2.7z)