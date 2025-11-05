**Category**: Miscellaneous  
**Author**: John Hammond

![](./files/01%20-%20Threat%20Actor%20Support%20Line/01%20-%20Threat%20Actor%20Support%20Line.png)

---

The website hosted on the challenge instance was pretty basic:

![](./files/01%20-%20Threat%20Actor%20Support%20Line/01.png)

Clicking the `Upload Archive` button opened a file selection dialogue. The three buttons below that expanded to this:

![](./files/01%20-%20Threat%20Actor%20Support%20Line/02.png)

I already knew from the challenge prompt that this would spin up a Windows VM and use the Administrator account. The site revealed that my files would then be processed by WinRAR v7.12, which is vulnerable to [CVE-2025-8088](https://nvd.nist.gov/vuln/detail/CVE-2025-8088). CVE-2025-8088 was originally an 0day that allowed a malicious archive to traverse directories and write files to unintended locations by abusing the Windows NTFS filesystem's [Alternate Data Streams](https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-fscc/c54dec26-1551-4d3a-a0ea-4fa40f848eb3) feature. This could be leveraged for remote code execution by writing executables to sensitive locations such as `%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup`. So the idea was to upload a malicious archive to trigger an arbitrary file write to that location, then upload another file to restart the VM and trigger the automatic startup execution.

First I downloaded [WinRAR v7.12](https://www.win-rar.com/fileadmin/winrar-versions/winrar/winrar-x64-712.exe) for Windows. Then I went looking for ways to recreate the exploit. I found [this proof-of-concept](https://github.com/onlytoxi/CVE-2025-8088-Winrar-Tool) on GitHub to be very nice. The code wasn't the cleanest, but the execution was very well done. It created a payload using an Alternate Data Stream and then patched the RAR headers (complete with signature fixup) to include the necessary path traversal. Most of the other proof-of-concept scripts I could find required cluttering up your Windows environment by dropping payloads into the intended directories before RAR creation had even begun. This method was much, much cleaner.

Now I needed a payload. I could've used an MSF payload or a C2 beacon, but I wanted to keep it simple. So I opted to use a fellow HackTheBox player's [Rust-based reverse shell](https://github.com/xct/rcat) and utilize its builtin functionality of automatically connecting to the IP and port specified in the filename.

So I created the malicious RAR and uploaded it twice; once to extract to the Administrator's startup folder and once to trigger it. Then I waited.

Finally, in my connectback listener:

```
$ rlwrap nc -vvlp 1337
listening on [any] 1337 ...
10.1.27.38: inverse host lookup failed: Unknown host
connect to [10.200.2.233] from (UNKNOWN) [10.1.27.38] 50116
Windows PowerShell 
Copyright (C) 2016 Microsoft Corporation. All rights reserved.

PS C:\ctf\threat-actor-support-line> type \flag.txt
flag{6529440ceec226f31a3b2dc0d0b06965}
```

Flag: **flag{6529440ceec226f31a3b2dc0d0b06965}**

---

**Files:**
- [CVE-2025-8088-Winrar-Tool-main.zip](./files//01%20-%20Threat%20Actor%20Support%20Line/CVE-2025-8088-Winrar-Tool-main.zip)
- [rcat.exe](./files//01%20-%20Threat%20Actor%20Support%20Line/rcat.exe)