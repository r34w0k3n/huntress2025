**Category**: Reverse Engineering  
**Author**: John Hammond

![](./files/02%20-%20NimCrackMe1/02%20-%20NimCrackMe1.png)

---

This was a pretty easy reverse engineering exercise, but definitely a good introduction to [Nim](https://nim-lang.org/) for those not already familiar.

The main function looked like this:

```C
__int64 main__crackme_u20()
{
  __int64 v1[2]; // [rsp+20h] [rbp-A0h] BYREF
  __int64 v2; // [rsp+30h] [rbp-90h] BYREF
  _QWORD *v3; // [rsp+38h] [rbp-88h]
  __int64 v4[2]; // [rsp+40h] [rbp-80h] BYREF
  __int64 v5[2]; // [rsp+50h] [rbp-70h] BYREF
  char v6[8]; // [rsp+60h] [rbp-60h] BYREF
  const char *v7; // [rsp+68h] [rbp-58h]
  __int64 v8; // [rsp+70h] [rbp-50h]
  const char *v9; // [rsp+78h] [rbp-48h]
  __int16 v10; // [rsp+80h] [rbp-40h]
  __int64 v11; // [rsp+90h] [rbp-30h] BYREF
  _QWORD *v12; // [rsp+98h] [rbp-28h]
  __int64 v13; // [rsp+A0h] [rbp-20h] BYREF
  _QWORD *v14; // [rsp+A8h] [rbp-18h]
  __int64 v15; // [rsp+B0h] [rbp-10h]
  _BYTE *v16; // [rsp+B8h] [rbp-8h]

  v7 = "main";
  v9 = "C:\\CTF\\nimcrackme1\\crackme.nim";
  v8 = 0i64;
  v10 = 0;
  nimFrame_8(v6);
  v16 = nimErrorFlag_6();
  v13 = 0i64;
  v14 = 0i64;
  v11 = 0i64;
  v12 = 0i64;
  v8 = 54i64;
  v9 = "C:\\CTF\\nimcrackme1\\crackme.nim";
  buildEncodedFlag__crackme_u18(&v13);
  if ( !*v16 )
  {
    v8 = 55i64;
    v2 = v13;
    v3 = v14;
    v1[0] = TM__cGo7QGde1ZstH4i7xlaOag_5;
    v1[1] = &TM__cGo7QGde1ZstH4i7xlaOag_4;
    xorStrings__crackme_u3(&v11, &v2, v1);
    if ( !*v16 )
    {
      v8 = 58i64;
      getTime__pureZtimes_u1281(v5);
      if ( !*v16 )
      {
        v15 = 0i64;
        v2 = v5[0];
        v3 = v5[1];
        v15 = toUnix__pureZtimes_u1230(&v2);
        if ( !*v16 )
        {
          if ( v15 )
          {
            v8 = 61i64;
            echoBinSafe(&TM__cGo7QGde1ZstH4i7xlaOag_6, 1i64);
          }
          else
          {
            v8 = 59i64;
            v4[0] = v11;
            v4[1] = v12;
            echoBinSafe(v4, 1i64);
          }
        }
      }
    }
  }
  v8 = 394i64;
  v9 = "C:\\CTF\\nim-2.2.4_x64\\nim-2.2.4\\lib\\system.nim";
  if ( v12 && (*v12 & 0x4000000000000000i64) == 0 )
    deallocShared(v12);
  if ( v14 && (*v14 & 0x4000000000000000i64) == 0 )
    deallocShared(v14);
  return popFrame_8();
}
```

The `buildEncodedFlag` function was 400+ lines of nested `if` statements:

```C
_QWORD *__fastcall buildEncodedFlag__crackme_u18(_QWORD *a1)
{
  _BYTE *v1; // rdx
  __int64 v3[2]; // [rsp+20h] [rbp-50h] BYREF
  char v4[8]; // [rsp+30h] [rbp-40h] BYREF
  const char *v5; // [rsp+38h] [rbp-38h]
  __int64 v6; // [rsp+40h] [rbp-30h]
  const char *v7; // [rsp+48h] [rbp-28h]
  __int16 v8; // [rsp+50h] [rbp-20h]
  __int64 v9; // [rsp+60h] [rbp-10h] BYREF
  _BYTE *v10; // [rsp+68h] [rbp-8h]

  v5 = "buildEncodedFlag";
  v7 = "C:\\CTF\\nimcrackme1\\crackme.nim";
  v6 = 0i64;
  v8 = 0;
  nimFrame_8(v4);
  v6 = 13i64;
  v7 = "C:\\CTF\\nimcrackme1\\crackme.nim";
  mnewString(v3, 38i64);
  v9 = v3[0];
  v10 = v3[1];
  v6 = 14i64;
  if ( v3[0] > 0 )
  {
    nimPrepareStrMutationV2(&v9);
    v10[8] = 40;
    v6 = 15i64;
    if ( v9 > 1 )
    {
      nimPrepareStrMutationV2(&v9);
      v10[9] = 5;
      v6 = 16i64;
      if ( v9 > 2 )
      {
        nimPrepareStrMutationV2(&v9);
        v10[10] = 12;
        v6 = 17i64;
        if ( v9 > 3 )
        {
          nimPrepareStrMutationV2(&v9);
          v10[11] = 71;
          v6 = 18i64;
          if ( v9 > 4 )
          {
            nimPrepareStrMutationV2(&v9);
            v10[12] = 18;
            v6 = 19i64;
            if ( v9 > 5 )
            {
              // Nesting continues here.
              // ...
  }
  else
  {
    raiseIndexError2(0i64, v9 - 1);
  }
  popFrame_8();
  v1 = v10;
  *a1 = v9;
  a1[1] = v1;
  return a1;
}
```

The above function just filled an array, byte by byte. The result was this:

```
28 05 0C 47 12 4B 15 5C 09 12 17 55 09 4B 42 08 55 5A 45 58 44 57 45 77 5D 54 44 5C 45 13 59 5B 47 42 5E 59 16 5D
```

The `xorStrings` function was also very straightforward:

```C
_QWORD *__fastcall xorStrings__crackme_u3(_QWORD *a1, __int64 *a2, __int64 *a3)
{
  __int64 v3; // rax
  __int64 v4; // rdx
  __int64 v5; // rdx
  __int64 v6; // rdx
  __int64 v8; // [rsp+0h] [rbp-C0h] BYREF
  __int64 v9[2]; // [rsp+20h] [rbp-A0h] BYREF
  __int64 v10; // [rsp+30h] [rbp-90h]
  __int64 v11; // [rsp+38h] [rbp-88h]
  __int64 v12; // [rsp+40h] [rbp-80h]
  __int64 v13; // [rsp+48h] [rbp-78h]
  __int64 v14; // [rsp+50h] [rbp-70h]
  __int64 v15; // [rsp+58h] [rbp-68h]
  const char *v16; // [rsp+68h] [rbp-58h]
  __int64 v17; // [rsp+70h] [rbp-50h]
  const char *v18; // [rsp+78h] [rbp-48h]
  __int16 v19; // [rsp+80h] [rbp-40h]
  __int64 v20; // [rsp+90h] [rbp-30h] BYREF
  __int64 v21; // [rsp+98h] [rbp-28h]
  __int64 v22; // [rsp+A8h] [rbp-18h]
  __int64 v23; // [rsp+B0h] [rbp-10h]
  __int64 v24; // [rsp+B8h] [rbp-8h]

  v3 = *a2;
  v4 = a2[1];
  v12 = v3;
  v13 = v4;
  v5 = a3[1];
  v10 = *a3;
  v11 = v5;
  v16 = "xorStrings";
  v18 = "C:\\CTF\\nimcrackme1\\crackme.nim";
  v17 = 0i64;
  v19 = 0;
  nimFrame_8(&v8 + 12);
  v20 = 0i64;
  v21 = 0i64;
  v17 = 6i64;
  if ( v12 >= 0 )
  {
    mnewString(v9, v12);
    v20 = v9[0];
    v21 = v9[1];
    v23 = 0i64;
    v22 = v12;
    v18 = "C:\\CTF\\nim-2.2.4_x64\\nim-2.2.4\\lib\\system\\iterators_1.nim";
    v24 = 0i64;
    v17 = 129i64;
    while ( v24 < v22 )
    {
      v18 = "C:\\CTF\\nimcrackme1\\crackme.nim";
      v23 = v24;
      v17 = 8i64;
      if ( v24 < 0 || v23 >= v20 )
      {
        raiseIndexError2(v23, v20 - 1);
        break;
      }
      nimPrepareStrMutationV2(&v20);
      if ( v23 < 0 || v23 >= v12 )
      {
        raiseIndexError2(v23, v12 - 1);
        break;
      }
      if ( !v10 )
      {
        raiseDivByZero();
        break;
      }
      v15 = v23 % v10;
      if ( v23 % v10 < 0 || v10 <= v15 )
      {
        raiseIndexError2(v15, v10 - 1);
        break;
      }
      *(v21 + v23 + 8) = *(v13 + v23 + 8) ^ *(v11 + v15 + 8);
      v17 = 131i64;
      v18 = "C:\\CTF\\nim-2.2.4_x64\\nim-2.2.4\\lib\\system\\iterators_1.nim";
      v14 = v24 + 1;
      if ( __OFADD__(1i64, v24) )
      {
        raiseOverflow();
        break;
      }
      v24 = v14;
    }
  }
  else
  {
    raiseRangeErrorI(v12, 0i64, 0x7FFFFFFFFFFFFFFFi64);
  }
  popFrame_8();
  v6 = v21;
  *a1 = v20;
  a1[1] = v6;
  return a1;
}
```

This was the byte array that was passed into `xorStrings` along with the encrypted flag:

```C
.rdata:0000000140021AE0 TM__cGo7QGde1ZstH4i7xlaOag_4 db  17h    ; DATA XREF: .rdata:off_140021B08↓o
.rdata:0000000140021AE1                 db    0
.rdata:0000000140021AE2                 db    0
.rdata:0000000140021AE3                 db    0
.rdata:0000000140021AE4                 db    0
.rdata:0000000140021AE5                 db    0
.rdata:0000000140021AE6                 db    0
.rdata:0000000140021AE7                 db  40h ; @
.rdata:0000000140021AE8                 db  4Eh ; N
.rdata:0000000140021AE9                 db  69h ; i
.rdata:0000000140021AEA                 db  6Dh ; m
.rdata:0000000140021AEB                 db  20h
.rdata:0000000140021AEC                 db  69h ; i
.rdata:0000000140021AED                 db  73h ; s
.rdata:0000000140021AEE                 db  20h
.rdata:0000000140021AEF                 db  6Eh ; n
.rdata:0000000140021AF0                 db  6Fh ; o
.rdata:0000000140021AF1                 db  74h ; t
.rdata:0000000140021AF2                 db  20h
.rdata:0000000140021AF3                 db  66h ; f
.rdata:0000000140021AF4                 db  6Fh ; o
.rdata:0000000140021AF5                 db  72h ; r
.rdata:0000000140021AF6                 db  20h
.rdata:0000000140021AF7                 db  6Dh ; m
.rdata:0000000140021AF8                 db  61h ; a
.rdata:0000000140021AF9                 db  6Ch ; l
.rdata:0000000140021AFA                 db  77h ; w
.rdata:0000000140021AFB                 db  61h ; a
.rdata:0000000140021AFC                 db  72h ; r
.rdata:0000000140021AFD                 db  65h ; e
.rdata:0000000140021AFE                 db  21h ; !
.rdata:0000000140021AFF                 db    0
```

The solution was thus quite simple:

```Python
#!/usr/bin/env python3
import binascii

def main():
    ct = binascii.unhexlify(b"28050C47124B155C09121755094B4208555A4558445745775D54445C4513595B47425E59165D")
    key = b"Nim is not for malware!"

    flag = ""

    for n in range(len(ct)):
        flag += chr(ct[n] ^ key[n% len(key)])

    print(flag)

if __name__ == "__main__":
    main()
```

```
$ python solve.py
flag{852ff73f9be462962d949d563743b86d}
```

Flag: **flag{852ff73f9be462962d949d563743b86d}**

---

**Files:**
- [nimcrackme1.exe](./files//02%20-%20NimCrackMe1/nimcrackme1.exe)
- [solve.py](./files//02%20-%20NimCrackMe1/solve.py)