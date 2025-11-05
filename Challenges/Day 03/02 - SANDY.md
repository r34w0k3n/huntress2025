**Category:** Malware  
**Author**: John Hammond

![](./files/02%20-%20SANDY/02%20-%20SANDY.png)

---

The challenge ZIP contained a Windows executable named `SANDY.exe`. Initial analysis revealed that it was packed with UPX.

```
$ upx -d -o SANDY_unpacked.exe SANDY.exe
                       Ultimate Packer for eXecutables
                          Copyright (C) 1996 - 2024
UPX 4.2.4       Markus Oberhumer, Laszlo Molnar & John Reiser    May 9th 2024

        File size         Ratio      Format      Name
   --------------------   ------   -----------   -----------
    567872 <-    342592   60.33%    win32/pe     SANDY_unpacked.exe

Unpacked 1 file.
```

Examining this file in IDA quickly revealed that it was a compiled [AutoIt](https://www.autoitscript.com/site/autoit/) script.

```C
int __stdcall wWinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPWSTR lpCmdLine, int nShowCmd)
{
  ::hInstance = hInstance;
  dword_4679DC = 0;
  dword_4679D8 = 0;
  dword_467A04 = 0;
  sub_401904();
  _set_new_handler(sub_4144F7);
  _set_new_mode(1);
  sub_412124();
  sub_401961(&unk_47BCF4, lpCmdLine);
  sub_40109D();
  sub_412178();
  return dword_4679DC;
}
```

```C
void __cdecl __noreturn sub_4144F7()
{
  MessageBoxW(0, L"Error allocating memory.", L"AutoIt", 0x10u);
  exit(1);
}
```

I used [this project](https://github.com/daovantrong/myAutToExe) from GitHub to decompile it. Starting on line 521 of the decompiled script was an array named `$base64Chunks` which contained nearly 1,400 base64 strings. I wrote a Python script to extract and decode those strings, revealing a PowerShell script that itself decoded multiple base64 strings before passing them to `Invoke-Expression`. I wrote another script to extract those and ended up with a third PowerShell script again decoding base64, but this time also employing AES encryption and GZIP compression. Continuing to decode the stages wasn't necessary at this point, however, as `stage3.ps1` also contained a JSON object named `$pathdata`, which was a list of browser extensions to target. At the very bottom of the list of Chrome extensions was the flag:

```JSON
...

"root": "%localappdata%\\Google\\Chrome\\User Data\\Default\\Extensions",
"targets": [
    ...
    
    {
        "name": "XMRpt-C",
        "path": "eigblbgjknlfbajkfhopmcojidlgcehm"
     },
     {
        "name": "Flag",
        "path": "flag{27768419fd176648b335aa92b8d2dab2}"
     }
     
...
```

Flag: **flag{27768419fd176648b335aa92b8d2dab2}**

---

**Files:**
- [SANDY.au3](./files//02%20-%20SANDY/SANDY.au3)
- [SANDY.exe](./files//02%20-%20SANDY/SANDY.exe)
- [sandy.py](./files//02%20-%20SANDY/sandy.py)
- [SANDY.zip](./files//02%20-%20SANDY/SANDY.zip)
- [SANDY_unpacked.exe](./files//02%20-%20SANDY/SANDY_unpacked.exe)
- [stage2.ps1](./files//02%20-%20SANDY/stage2.ps1)
- [stage2.py](./files//02%20-%20SANDY/stage2.py)
- [stage3.ps1](./files//02%20-%20SANDY/stage3.ps1)