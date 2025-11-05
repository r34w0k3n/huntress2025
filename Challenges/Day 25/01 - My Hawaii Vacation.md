**Category**: Malware  
**Author**: John Hammond

![](./files/01%20-%20My%20Hawaii%20Vacation/01%20-%20My%20Hawaii%20Vacation.png)

---

Visiting the challenge instance in a browser would immediately display a popup:

![](./files/01%20-%20My%20Hawaii%20Vacation/01.png)

Filling it in and clicking the `Done` button would then trigger a download:

![](./files/01%20-%20My%20Hawaii%20Vacation/02.png)

Upon examining this binary in IDA, the Hawaii hints immediately clicked; [Lua](https://www.lua.org/start.html).

If you've ever reverse engineered embedded Lua before, this binary wasn't much different. There was a `lua_State` pointer that got passed into most functions and you'd see all the usual telltale strings, such as this one:

![](./files/01%20-%20My%20Hawaii%20Vacation/03.png)

Something that's also incredibly common in these scenarios is precompiled Lua bytecode will get loaded from *somewhere* and executed. That process will look different depending on how intricate the coupling between the host program and the Lua VM are, but generally speaking it's going to start with locating and loading the bytecode. In this instance, tracing that wasn't too difficult. Starting from `main` I jumped to `sub_0410C0` and then `sub_4011C0`:

```C
int __cdecl sub_4011C0(int a1, char *FileName)
{
  FILE *v2; // eax
  FILE *v3; // esi
  char *v4; // eax
  char *v5; // eax
  char *v6; // eax
  char *v7; // eax
  FILE *Stream; // [esp+Ch] [ebp-21Ch]
  char Buffer[8]; // [esp+10h] [ebp-218h] BYREF
  int Offset; // [esp+18h] [ebp-210h]
  int v12; // [esp+1Ch] [ebp-20Ch]
  int v13[130]; // [esp+20h] [ebp-208h] BYREF

  v2 = fopen(FileName, Mode);
  v3 = v2;
  Stream = v2;
  if ( !v2 )
  {
    v4 = strerror(ErrorMessage);
    sub_402E40(a1, "cannot %s %s: %s", aOpen, FileName, v4); // "open"
  }
  if ( fseek(v2, -16, 2) )
  {
    v5 = strerror(ErrorMessage);
    sub_402E40(a1, "cannot %s %s: %s", aSeek, FileName, v5); // "seek"
  }
  if ( fread(Buffer, 0x10u, 1u, v3) != 1 )
  {
    v6 = strerror(ErrorMessage);
    sub_402E40(a1, "cannot %s %s: %s", aRead, FileName, v6); // "read"
  }
  if ( memcmp(Buffer, aGlueL, 8u) ) // "%%glue:L"
    sub_402E40(a1, "no Lua program found in %s", FileName);
  if ( fseek(Stream, Offset, 0) )
  {
    v7 = strerror(ErrorMessage);
    sub_402E40(a1, "cannot %s %s: %s", aSeek, FileName, v7); // "seek"
  }
  v13[0] = Stream;
  v13[1] = v12;
  if ( sub_4028B0(a1, sub_401320, v13, FileName) )
    sub_402A30(a1);
  return fclose(Stream);
}
```

I was never able to figure out *how* this was embedded, such as what public project (if any) was used etc. But it was clear from the above code that the bytecode was embedded in the executable and then a small "stub" was appended to the file; 16 bytes holding a signature, a file offset and the length of the bytecode.

```
00044ed0: 2525 676c 7565 3a4c 0010 0300 cf3e 0100    %%glue:L.....>..
```

Knowing this, I used the following script to carve out the Lua bytecode:

```Python
#!/usr/bin/env python3
#!/usr/bin/env python3
import struct

def main():
    data = open("Booking - ID Verification.exe", "rb").read()
    tail = data[-16:]

    offset = struct.unpack("<I", tail[8:12])[0]
    length = struct.unpack("<I", tail[12:])[0]

    print("offset = %08x" % offset)
    print("length = %08x" % length)

    lua = data[offset:offset+length]

    with open("sample.bin", "wb") as fout:
        fout.write(lua)

if __name__ == "__main__":
    main()
```

Checking the first few bytes of `sample.bin` with `xxd` confirmed that it was indeed Lua bytecode:

```
$ xxd sample.bin       
00000000: 1b4c 7561 5100 0104 0404 0800 4700 0000  .LuaQ.......G...
00000010: 4043 3a5c 5769 6e64 6f77 735c 5445 4d50  @C:\Windows\TEMP
00000020: 5c6c 7561 2d62 7569 6c64 2d34 6266 3866  \lua-build-4bf8f
00000030: 6432 3738 3837 6534 3861 3139 3435 3834  d27887e48a194584
00000040: 6465 3863 6638 6464 3634 665c 636f 6e63  de8cf8dd64f\conc
00000050: 6174 2e6c 7561 0000 0000 0000 0000 0000  at.lua..........
...
```

At this point I downloaded, built and executed [unluac](https://github.com/HansWessels/unluac).

```
$ java -jar unluac.jar sample.bin > sample.lua
```

The resulting Lua source file looked *mostly* normal, but the strings were a bit odd:

```Lua
...
local __E_SPACE = "\240\159\144\160\240\159\144\153"
...
```

Everything was an emoji! Thankfully the sample contained the necessary objects and functions to decode them (`__K`, `__T`, `__P` and `__D`).

```Python
#!/usr/bin/env python3
import re

def main():
    data = open("sample.lua").read()

    with open("decode.lua", "w") as fout:
        # Include __K, __T, __P and __D in the output.
        fout.write("\n".join(data.split("\n")[25:137]) + "\n")

        # Include all __D(string_here, __K) calls in the output.
        for item in re.findall(r"__D\(\"[^\"]+?\", __K\)", data):
            fout.write("print(%s);\n" % item)
    
if __name__ == "__main__":
    main()
```

```
$ python extract.py
$ ./lua-5.1/src/lua decode.lua
...
powershell.exe -NoProfile -Command "Get-CimInstance -ClassName Win32_UserAccount | Where-Object { Test-Path (Join-Path -Path 'C:\Users' -ChildPath $_.Name) } | Select-Object Name,SID | Format-List"
r
*all
Name
SID
\
COMPUTERNAME
_
.log
powershell.exe -NoProfile -Command "(Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\
').Sid > 
"
http://10.1.52.187/a9GeV5t1FFrTqNXUN2vaq93mNKfSDqESBn2IlNiGRvh6xYUsQFEk4rRo8ajGA7fiEDe1ugdmAbCeqXw6y0870YkBqU1hrVTzgDIHZplop8WAWTiS3vQPOdNP
prometheus
PA4tqS5NHFpkQwumsd3D92cb
C:\Users\
http://10.1.52.187/a9GeV5t1FFrTqNXUN2vaq93mNKfSDqESBn2IlNiGRvh6xYUsQFEk4rRo8ajGA7fiEDe1ugdmAbCeqXw6y0870YkBqU1hrVTzgDIHZplop8WAWTiS3vQPOdNP
prometheus
PA4tqS5NHFpkQwumsd3D92cb
```

There was more output, but the above was the most relevant stuff. I could see something being done with an account SID, a URL and login credentials.

```
$ curl -u 'prometheus:PA4tqS5NHFpkQwumsd3D92cb' 'http://10.1.52.187/a9GeV5t1 ...'
<!doctype html>
<html>
  <head><meta charset="utf-8"><title>Uploaded files</title></head>
  <body>
    <h1>Uploaded files</h1>
    
      <ul>
      
        <li><a href="/uploads/WINDOWS11-Administrator.log">WINDOWS11-Administrator.log</a></li>
      
        <li><a href="/uploads/WINDOWS11-Administrator.zip">WINDOWS11-Administrator.zip</a></li>
      
      </ul>
    
  </body>
</html>
```

```
$ curl -q -u 'prometheus:PA4tqS5NHFpkQwumsd3D92cb' 'http://10.1.52.187/uploads/WINDOWS11-Administrator.log' -o admin.log
$ curl -q -u 'prometheus:PA4tqS5NHFpkQwumsd3D92cb' 'http://10.1.52.187/uploads/WINDOWS11-Administrator.zip' -o admin.zip
$ cat admin.log
1
5
0
0
0
0
0
5
21
0
0
0
18
239
154
226
242
155
126
245
147
116
180
120
244
1
0
0

$ file admin.zip
admin.zip: Zip archive data, made by v2.0 UNIX, extract using at least v2.0, last modified Oct 04 2025 21:50:30, uncompressed size 0, method=AES Encrypted
```

Presumably the SID was the ZIP password, but it was in raw/binary format. Luckily I wrote a script for a recent HackTheBox machine where I needed to be able to convert SIDs to their string representation. I just needed to convert it to hexadecimal format first, which was easy.

```
$ python -c 'print(bytes([int(o.strip()) for o in open("admin.log").readlines()]).hex())'
01050000000000051500000012ef9ae2f29b7ef59374b478f4010000
```

```Python
#!/usr/bin/env python3
import sys
import binascii
    
def usage():
    print("Usage: %s <sidhex>" % sys.argv[0])
    sys.exit()
    
def main():
    if len(sys.argv) < 2:
        usage()
        
    # https://learn.microsoft.com/en-us/windows/win32/api/winnt/ns-winnt-sid
    # https://learn.microsoft.com/en-us/windows/win32/api/winnt/ns-winnt-sid_identifier_authority
    
    # typedef struct _SID {
    #   BYTE                     Revision;
    #   BYTE                     SubAuthorityCount;
    #   SID_IDENTIFIER_AUTHORITY IdentifierAuthority;
    #   DWORD                    *SubAuthority[];
    #   DWORD                    SubAuthority[ANYSIZE_ARRAY];
    # } SID, *PISID;
    #
    # typedef struct _SID_IDENTIFIER_AUTHORITY {
    #   BYTE Value[6];
    # } SID_IDENTIFIER_AUTHORITY, *PSID_IDENTIFIER_AUTHORITY;
    
    # 01                | revision
    # 05                | subauthority count
    # 00 00 00 00 00 05 | identifier authority (predefined values of 0-9)
    # 15 00 00 00       | subauthority 1
    # 5b 7b b0 f3       | subauthority 2
    # 98 aa 22 45       | subauthority 3
    # ad 4a 1c a4       | subauthority 4
    # 4f 04 00 00       | subauthority 5
        
    hex_bytes = binascii.unhexlify(sys.argv[1])
    
    revision = hex_bytes[0]
    subcount = hex_bytes[1]
    
    authority = int.from_bytes(hex_bytes[2:8], "big")
    
    sid = f"S-%i-%i" % (revision, authority)
    
    for n in range(8, 8+(4*subcount), 4):
        sid += "-%i" % int.from_bytes(hex_bytes[n:n+4], "little")
    
    print(sid)    
    
if __name__ == "__main__":
    main()
```

```
$ python hex2sid.py 01050000000000051500000012ef9ae2f29b7ef59374b478f4010000
S-1-5-21-3801804562-4118715378-2025092243-500

$ 7z x -so admin.zip "Desktop/flag.txt" -pS-1-5-21-3801804562-4118715378-2025092243-500
flag{0a741a06d3b8227f75773e3195e1d641}
```

Flag: **flag{0a741a06d3b8227f75773e3195e1d641}**

---

**Files:**
- [admin.log](./files//01%20-%20My%20Hawaii%20Vacation/admin.log)
- [admin.zip](./files//01%20-%20My%20Hawaii%20Vacation/admin.zip)
- [Booking - ID Verification.exe](./files//01%20-%20My%20Hawaii%20Vacation/Booking%20-%20ID%20Verification.exe)
- [carve.py](./files//01%20-%20My%20Hawaii%20Vacation/carve.py)
- [decode.lua](./files//01%20-%20My%20Hawaii%20Vacation/decode.lua)
- [extract.py](./files//01%20-%20My%20Hawaii%20Vacation/extract.py)
- [sample.bin](./files//01%20-%20My%20Hawaii%20Vacation/sample.bin)
- [sample.exe](./files//01%20-%20My%20Hawaii%20Vacation/sample.exe)
- [sample.lua](./files//01%20-%20My%20Hawaii%20Vacation/sample.lua)