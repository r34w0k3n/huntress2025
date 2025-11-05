**Category**: Forensics  
**Author**: John Hammond

![](./files/01%20-%20I%20Forgot/01%20-%20I%20Forgot.png)

---

Note: The challenge ZIP was too big to upload to GitHub as a single file, so I split it up into parts. You can reconstitute it like so:

```
$ ls -lha              
total 374M
drwxrwxr-x  2 user user  120 Nov  4 18:45 .
drwxrwxrwt 20 root root 2.2K Nov  4 18:32 ..
-rw-rw-r--  1 user user  95M Nov  4 18:43 i_forgot.part-aa
-rw-rw-r--  1 user user  95M Nov  4 18:43 i_forgot.part-ab
-rw-rw-r--  1 user user  95M Nov  4 18:43 i_forgot.part-ac
-rw-rw-r--  1 user user  89M Nov  4 18:43 i_forgot.part-ad

$ cat i_forgot.part-* > i_forgot.zip
$ md5sum i_forgot.zip
97f0154f0743a96c6e9c4192d1d1e847  i_forgot.zip
```

---

The challenge ZIP contained two files: `flan.enc` and `memdmp.dmp`.

[Volatility 3](https://github.com/volatilityfoundation/volatility3) revealed the presence of an executable name `BackupHelper.exe` on the user's desktop, but I was never able to get it to dump the file. Searching through the strings in the memory dump for references to the desktop yielded a number of results:

```
$ grep -ni 'C:\\Users\\User\\Desktop' strings.txt
...
1008179:"C:\Users\User\Desktop\BackupHelper.exe" C:\Users\User\Desktop\DECRYPT_PRIVATE_KEY.zip 
1008186:"C:\WINDOWS\system32\notepad.exe" C:\Users\User\Desktop\INSTRUCTIONS_FOR_DECRYPTION.txt 
1008188:C:\Windows\Microsoft.NET\Framework64\v4.0.30319\cvtres.exe /NOLOGO /READONLY /MACHINE:IX86 "/OUT:C:\Users\User\AppData\Local\Temp\RES49E5.tmp" "c:\Users\User\Desktop\C0-9A-Za-z
1362232:!C:\Users\User\Desktop\memdump.exe
1362267:!C:\Users\User\Desktop\DECRYPT_PRIVATE_KEY.zip
1397697:c:\users\user\desktop\moneybird\x64\release\moneybird
1777233:c:\users\user\desktop\moneybird\x64\release\moneybird
1968659:!C:\Users\User\Desktop\memdump.exe
1968694:!C:\Users\User\Desktop\DECRYPT_PRIVATE_KEY.zip
2218881:c:\Users\User\Desktop\2005\DlgSmpl\WinRel\DlgSmpl.pdbDlgSmplTrojanDropper:O97M/GraceWire.S!MSR
2413428:5c:\Users\User\Desktop\commap\ctlcomm\Release\ctlcomm.pdbBehavior:Win32/MshtaDropsXsl.B!attk
2525663:C:\Users\User\Desktop\memdump.exe
2525669:C:\Users\User\Desktop\BackupHelper.exe
2540156:c:\Users\User\Desktop\2003\calcdriv\Release\calcdriv.pdbcalcdriv.exeSleepm
2551661:c:\users\user\desktop\moneybird\x64\release\moneybird
2617522:top\openssl-1.0.1e_m\/ssl/cert.pemC:\Users\User\Desktop\Downloader_Pocow
2803270:ZipPath: C:\Users\User\Desktop\DECRYPT_PRIVATE_KEY.zip
3003628:"C:\Users\User\Desktop\memdump.exe" memdump.dmp
3147694:c:\Users\User\Desktop\2005\DlgSmpl\WinRel\DlgSmpl.pdbDlgSmplTrojanDropper:O97M/GraceWire.S!MSR
3535281:c:\users\user\desktop\backuphelper.exeExecutedPENoCert
3535294:C:\Users\User\Desktop\DECRYPT_PRIVATE_KEY.zipNewlyCreatedZip
3577027:c:\users\user\desktop\zver\
3977788:C:\Users\user\Desktop\WindowsApplication1\WindowsApplication1\obj\x86\Release\Windows Application.pdb\
4165301:!C:\Users\User\Desktop\BackupHelper.cs
4165322:ZipPath: C:\Users\User\Desktop\DECRYPT_PRIVATE_KEY.zip
4165328:!C:\Users\User\Desktop\BackupHelper_log.txt
4165345:!C:\Users\User\Desktop\BackupHelper.exe
5547951:!C:\Users\User\Desktop\BackupHelper.cs
5547972:ZipPath: C:\Users\User\Desktop\DECRYPT_PRIVATE_KEY.zip
5547978:!C:\Users\User\Desktop\BackupHelper_log.txt
5547995:!C:\Users\User\Desktop\BackupHelper.exe
...
```

I'm not very well versed in Volatility so all my attempts to using it dump any of those files just failed. Similarly, every ZIP file that `scalpel` managed to carve out was corrupted and useless. Out of sheer frustration I decided to just use whatever vibe coded garbage ChatGPT spat out at me.

```Python
#!/usr/bin/env python3
import os
import sys
import struct

EOCD_SIG = b'PK\x05\x06'
CD_FILE_HEADER_SIG = b'PK\x01\x02'
LOCAL_FILE_SIG = b'PK\x03\x04'
ZIP64_EOCD_SIG = b'PK\x06\x06'

def find_all(data, needle):
    i = 0
    while True:
        i = data.find(needle, i)
        if i == -1:
            break
        yield i
        i += 1

def parse_eocd(data, pos):
    if pos + 22 > len(data):
        return None
    chunk = data[pos:pos+22]
    sig, dnum, dstart, n1, n2, cd_size, cd_offset, comment_len = struct.unpack('<4sHHHHIIH', chunk)
    if sig != EOCD_SIG:
        return None
    return {
        'pos': pos,
        'cd_size': cd_size,
        'cd_offset': cd_offset,
        'comment_len': comment_len,
        'eocd_total_size': 22 + comment_len
    }

def parse_central_directory_entries(data, cd_start, cd_size):
    entries = []
    p = cd_start
    cd_end = cd_start + cd_size
    while p + 46 <= cd_end:
        if data[p:p+4] != CD_FILE_HEADER_SIG:
            return None
        try:
            (sig, ver_made, ver_need, flags, comp, modt, modd,
             crc32, comp_size, uncomp_size,
             fname_len, extra_len, comment_len,
             diskstart, int_attr, ext_attr, local_hdr_off) = struct.unpack_from('<4sHHHHHHIIIHHHHLH I', data, p)
        except Exception:
            local_hdr_off = struct.unpack_from('<I', data, p + 42)[0]
            fname_len = struct.unpack_from('<H', data, p + 28)[0]
            extra_len = struct.unpack_from('<H', data, p + 30)[0]
            comment_len = struct.unpack_from('<H', data, p + 32)[0]
        entries.append({
            'cd_entry_pos': p,
            'local_header_offset': local_hdr_off,
            'fname_len': fname_len,
            'extra_len': extra_len,
            'comment_len': comment_len
        })
        p += 46 + entries[-1]['fname_len'] + entries[-1]['extra_len'] + entries[-1]['comment_len']
    return entries

def safe_unpack(fmt, data, offset):
    try:
        return struct.unpack_from(fmt, data, offset)
    except Exception:
        return None

def try_extract_archive(data, eocd_pos, outdir, index):
    eocd = parse_eocd(data, eocd_pos)
    if not eocd:
        return False
    cd_size = eocd['cd_size']
    cd_offset = eocd['cd_offset']
    comment_len = eocd['comment_len']
    eocd_total_size = eocd['eocd_total_size']

    archive_start = eocd_pos - (cd_offset + cd_size)
    if archive_start < 0:
        return False

    cd_start = archive_start + cd_offset
    cd_end = cd_start + cd_size
    if cd_end > eocd_pos:
        return False
    if data[cd_start:cd_start+4] not in (CD_FILE_HEADER_SIG,):
        found = False
        for delta in range(-64, 65):
            p = cd_start + delta
            if 0 <= p < len(data)-4 and data[p:p+4] == CD_FILE_HEADER_SIG:
                cd_start = p
                found = True
                break
        if not found:
            return False

    entries = parse_central_directory_entries(data, cd_start, cd_size)
    if entries is None or len(entries) == 0:
        return False

    for ent in entries:
        local_abs = archive_start + ent['local_header_offset']
        if not (0 <= local_abs < len(data)-4):
            return False
        if data[local_abs:local_abs+4] != LOCAL_FILE_SIG:
            return False

    eocd_end_pos = eocd_pos + eocd_total_size
    out_name = os.path.join(outdir, f'found_zip_{index:04d}.zip')
    with open(out_name, 'wb') as out:
        out.write(data[archive_start:eocd_end_pos])
    print(f'[+] Extracted {out_name} (start=0x{archive_start:x} end=0x{eocd_end_pos:x}, {len(entries)} entries)')
    return True

def main():
    if len(sys.argv) < 3:
        print("Usage: extract_zips_from_mem.py <memory_image> <out_dir>")
        sys.exit(1)
    memfile = sys.argv[1]
    outdir = sys.argv[2]
    os.makedirs(outdir, exist_ok=True)
    with open(memfile, 'rb') as f:
        data = f.read()

    eocd_positions = list(find_all(data, EOCD_SIG))
    print(f'Found {len(eocd_positions)} EOCD candidate(s). Scanning...')

    extracted = 0
    used_eocd_positions = set()
    for i, pos in enumerate(eocd_positions):
        if any(abs(pos - p) < 4 for p in used_eocd_positions):
            continue
        ok = try_extract_archive(data, pos, outdir, extracted+1)
        if ok:
            extracted += 1
            used_eocd_positions.add(pos)
    print(f'Done. Extracted {extracted} ZIP(s).')

if __name__ == '__main__':
    main()
```

```
$ python extract.py memdump.dmp .    
Found 28 EOCD candidate(s). Scanning...
[+] Extracted ./found_zip_0001.zip (start=0x38f35000 end=0x38f35792, 2 entries)
Done. Extracted 1 ZIP(s).
```

This worked, but the extracted ZIP file was encrypted.

```
$ unzip found_zip_0001.zip
Archive:  found_zip_0001.zip
[found_zip_0001.zip] private.pem password:
```

I wondered if perhaps a plaintext password could be found in the memory dump.

```
$ grep -ni 'password' strings.txt
...
6074556:ZIP password: ePDaACdOCwaMiYDG
...
```

That ended up working.

```
$ unzip found_zip_0001.zip
Archive:  found_zip_0001.zip
[found_zip_0001.zip] private.pem password: 
  inflating: private.pem             
 extracting: key.enc
```

I carved out the IV and key from key.enc and then passed everything into OpenSSL to decrypt:

```
$ openssl pkeyutl -decrypt -inkey private.pem -in key.enc -out key.bin -pkeyopt rsa_padding_mode:oaep

$ dd if=flag.enc bs=1 count=16 of=iv.bin
16+0 records in
16+0 records out
16 bytes copied, 0.0022315 s, 7.2 kB/s

$ dd if=flag.enc bs=1 skip=16 of=ct.bin
192+0 records in
192+0 records out
192 bytes copied, 0.0224545 s, 8.6 kB/s

$ openssl enc -d -aes-256-cbc -in ct.bin -out flag.txt -K "$(xxd -p -c 48 key.bin)" -iv "$(xxd -p -c 16 iv.bin)"
hex string is too long, ignoring excess

$ cat flag.txt
 RECOVERY ===
Note: This file contains the recovered data for decryption.
-----------------------------
FLAG:
flag{fa838fa9823e5d612b25001740faca31}
-----------------------------
```

Flag: **flag{fa838fa9823e5d612b25001740faca31}**

---

**Files:**
- [extract.py](./files//01%20-%20I%20Forgot/extract.py)
- [files.txt](./files//01%20-%20I%20Forgot/)
- [flag.enc](./files//01%20-%20I%20Forgot/flag.enc)
- [flag.txt](./files//01%20-%20I%20Forgot/flag.txt)
- [iv.bin](./files//01%20-%20I%20Forgot/iv.bin)
- [i_forgot.part-aa](./files//01%20-%20I%20Forgot/i_forgot.part-aa)
- [i_forgot.part-ab](./files//01%20-%20I%20Forgot/i_forgot.part-ab)
- [i_forgot.part-ac](./files//01%20-%20I%20Forgot/i_forgot.part-ac)
- [i_forgot.part-ad](./files//01%20-%20I%20Forgot/i_forgot.part-ad)
- [key.bin](./files//01%20-%20I%20Forgot/key.bin)
- [key.enc](./files//01%20-%20I%20Forgot/key.enc)
- [strings.txt](./files//01%20-%20I%20Forgot/strings.txt)