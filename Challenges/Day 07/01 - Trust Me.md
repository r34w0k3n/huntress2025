**Category**: Miscellaneous  
**Author**: John Hammond

![](./files/01%20-%20Trust%20Me/01%20-%20Trust%20Me.png)

---

The goal of this challenge was to get players to figure how to run a process as TrustedInsaller, but I found that kind of boring. I decided to turn this into a reverse engineering challenge instead. I began by exfiltrating `C:\Users\Administrator\Desktop\TrustMe.exe` over SMB and then opened it in IDA.

The top half of the `WinMain` function looked like this:

```C
  Sid = 0i64;
  if ( !ConvertStringSidToSidA(StringSid, &Sid) )
  {
    MessageBoxA(0i64, "Internal error: SID conversion failed.", "Error", 0x10u);
    return 2;
  }
  IsMember = 0;
  if ( !CheckTokenMembership(0i64, Sid, &IsMember) )
  {
    LocalFree(Sid);
    MessageBoxA(0i64, "Internal error: token check failed.", "Error", 0x10u);
    return 3;
  }
  if ( !IsMember )
  {
    LocalFree(Sid);
    MessageBoxA(
      0i64,
      "I don't trust ya! I'll give you the flag... but only if you have Trusted Installer permissions!",
      "Access denied",
      0x30u);
    return 1;
  }
  v5 = fopen(off_14001D008, "rb");
  v6 = v5;
  if ( !v5 )
  {
    LocalFree(Sid);
    MessageBoxA(0i64, "Could not open key.bin. Are permissions set for TrustedInstaller only?", "Key error", 0x10u);
    return 4;
  }
  v7 = fread(Buffer, 1ui64, 0x20ui64, v5);
  fclose(v6);
  if ( v7 != 32 )
  {
    LocalFree(Sid);
    MessageBoxA(0i64, "key.bin must be exactly 32 bytes (AES-256 key).", "Key error", 0x10u);
    return 5;
  }
  v8 = 0i64;
  v9 = ::Str;
  v10 = strlen(::Str);
  v11 = j__malloc_base(3 * ((v10 >> 2) + 1));
  if ( !v11 )
  {
    v11 = 0i64;
    goto LABEL_34;
  }
```

It read in a `key.bin` file and then allocated a buffer for some arbitrary string. Immediately below was a loop containing this:

```C
LABEL_34:
  if ( (v8 & 0xF) != 0 )
  {
    wsprintfA(v29, "Cipher length %u is not a multiple of 16.\nBase64 likely corrupted.", v8);
    v19 = "Bad ciphertext";
    v20 = v29;
```

So the ciphertext was base64 encoded, which could also be seen in IDA:

```C
.rdata:0000000140012480 aWx6eetgxddnmct db 'Wx6eETGXddnmCT4qZ7BxgRYpC+kdjjFzXxW+BM4HiI3GPaslpFBnpk9XplnaSxNg',0
.rdata:0000000140012480                                         ; DATA XREF: .data:Str↓o
.rdata:00000001400124C1                 align 8
.rdata:00000001400124C8 unk_1400124C8   db    4                 ; DATA XREF: WinMain+2EA↑o
.rdata:00000001400124C9                 db 0C9h
.rdata:00000001400124CA                 db 0E6h
.rdata:00000001400124CB                 db  53h ; S
.rdata:00000001400124CC                 db  65h ; e
.rdata:00000001400124CD                 db  56h ; V
.rdata:00000001400124CE                 db  8Dh
.rdata:00000001400124CF                 db  0Fh
.rdata:00000001400124D0                 db  8Ah
.rdata:00000001400124D1                 db    2
.rdata:00000001400124D2                 db 0F5h
.rdata:00000001400124D3                 db  26h ; &
.rdata:00000001400124D4                 db 0BAh
.rdata:00000001400124D5                 db    0
.rdata:00000001400124D6                 db 0FCh
.rdata:00000001400124D7                 db  5Bh ; [
.rdata:00000001400124D8 aCCtfKeyBin     db 'C:\\ctf\\key.bin',0 ; DATA XREF: .data:off_14001D008↓o
.rdata:00000001400124E9                 align 10h
```

Following the ciphertext was presumably the IV and a filepath for the key. The pivotal question was could I access that key?

![](./files/01%20-%20Trust%20Me/01.png)

Yes I could. After decoding and decryption, the flag got passed into a much larger function that seemed to create a special GUI window for viewing the flag, but reverse engineering that at this stage would have been pointless. I wrote a Python script to use what I had to decrypt the flag.

```Python
#!/usr/bin/env python3
import base64
from Crypto.Cipher import AES
from Crypto.Util.Padding import unpad

def main():
    flag = base64.b64decode(b"Wx6eETGXddnmCT4qZ7BxgRYpC+kdjjFzXxW+BM4HiI3GPaslpFBnpk9XplnaSxNg")
    iv = b"\x04\xC9\xE6\x53\x65\x56\x8D\x0F\x8A\x02\xF5\x26\xBA\x00\xFC\x5B"
    key = base64.b64decode(b"xck724QVNPrlVF7csPEgQdEM1NkO4Wp9gjX6ZXyTgl0=")

    cipher = AES.new(key, AES.MODE_CBC, iv=iv)
    
    print(unpad(cipher.decrypt(flag), AES.block_size).decode().strip())
   
if __name__ == "__main__":
    main()
```

```
$ python solve.py
flag{c6065b1f12395d526595e62cf1f4d82a}
```

Flag: **flag{c6065b1f12395d526595e62cf1f4d82a}**

---

**Files:**
- [key.bin](./files//01%20-%20Trust%20Me/key.bin)
- [solve.py](./files//01%20-%20Trust%20Me/solve.py)
- [TrustMe.exe](./files//01%20-%20Trust%20Me/TrustMe.exe)