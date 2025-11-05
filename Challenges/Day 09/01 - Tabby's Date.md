**Category**: Forensics  
**Author**: John Hammond

![](./files/01%20-%20Tabby%27s%20Date/01%20-%20Tabby%27s%20Date.png)

---

The challenge ZIP contained a backup of Tabby's `C:\` drive. Most of the files were useless, but there were 39 Windows Notepad "TabState" `.bin` files under `C:\Users\Tabby\AppData\Local\Packages\Microsoft.WindowsNotepad_8wekyb3d8bbwe\LocalState\TabState\`. Examining one of these files with `xxd` revealed that they were filled with Windows [wide-character](https://learn.microsoft.com/en-us/cpp/c-runtime-library/unicode-the-wide-character-set?view=msvc-170) strings.

![](./files/01%20-%20Tabby%27s%20Date/01.png)

```
$ strings -e l *.bin | grep flag
they told me the password is: flag{165d19b610c02b283fc1a6b4a54c4a58}
```

Flag: **flag{165d19b610c02b283fc1a6b4a54c4a58}**

---

**Files:**
- [tabbys_date.zip](./files//01%20-%20Tabby%27s%20Date/tabbys_date.zip)