**Category**: Reverse Engineering  
**Author**: Nordgaren

![](./files/01%20-%20Rust%20Tickler%203/01%20-%20Rust%20Tickler%203.png)

---

This was mostly solved by my teammate XeroExecute. Here's a link to his writeup: https://xeroexecute.github.io/posts/rusttickler3/

The first half of this challenge was essentially a repeat of [Rust Tickler 2](../Day%2028/01%20-%20Rust%20Tickler%202.md); dumping encrypted strings from memory. However, this time there was no flag. During dynamic analysis with [API Monitor](http://www.rohitab.com/apimonitor), I noticed calls to [CreateFile](https://learn.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-createfilea) attempting to dump something into a temporary file in `%LOCALAPPDATA%\Temp` and then move it to `%APPDATA%\Exodus` as `rust-tickler-3-stage-2.exe`. I was able to grab that temporary file from my maldev environment and begin analyzing it.

![](./files/01%20-%20Rust%20Tickler%203/01.png)

I was kind of burnt out at this stage, as I had just finished both [No Limits](../Day%2030/02%20-%20No%20Limits.md) and [Root Canal](../Day%2031/01%20-%20Root%20Canal.md) *and* had upcoming HackTheBox content to prepare for, so for the most part I just handed it off to my team. XeroExecute ended up absolutely killing it, so definitely check out his [writeup](https://xeroexecute.github.io/posts/rusttickler3/).

This marked our final solve, 100% completion and brought us to standing #24.

![](./files/01%20-%20Rust%20Tickler%203/02.png)

Flag: **flag{fb8de641f383151222845d9b991a17c2}**

---

**Files:**
- [rust-tickler-3-stage-2.exe](./files//01%20-%20Rust%20Tickler%203/rust-tickler-3-stage-2.exe)
- [rust-tickler-3.7z](./files//01%20-%20Rust%20Tickler%203/rust-tickler-3.7z)