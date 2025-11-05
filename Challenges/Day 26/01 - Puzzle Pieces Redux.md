**Category**: Forensics  
**Author**: Nordgaren

![](./files/01%20-%20Puzzle%20Pieces%20Redux/01%20-%20Puzzle%20Pieces%20Redux.png)

---

The challenge archive contained 16 `.bin` files that were all the same size:

```
$ ls -lha puzzle-pieces-2-final
total 2.2M
drwxrwxrwx 1 root root 4.0K Oct 26 04:19 .
drwxrwxrwx 1 root root    0 Oct 29 18:54 ..
-rwxrwxrwx 1 root root 140K Oct 26 04:17 07c8b8cb6a9.bin
-rwxrwxrwx 1 root root 140K Oct 26 04:17 1a1962fc.bin
-rwxrwxrwx 1 root root 140K Oct 26 04:17 20a.bin
-rwxrwxrwx 1 root root 140K Oct 26 04:17 3511c0a625.bin
-rwxrwxrwx 1 root root 140K Oct 26 04:17 5eb6e6c8.bin
-rwxrwxrwx 1 root root 140K Oct 26 04:17 64b.bin
-rwxrwxrwx 1 root root 140K Oct 26 04:16 6676585.bin
-rwxrwxrwx 1 root root 140K Oct 26 04:17 7c8394d4b6b0.bin
-rwxrwxrwx 1 root root 140K Oct 26 04:17 99fa27fd897.bin
-rwxrwxrwx 1 root root 140K Oct 26 04:17 a6ffddda.bin
-rwxrwxrwx 1 root root 140K Oct 26 04:17 a891a220.bin
-rwxrwxrwx 1 root root 140K Oct 26 04:17 abc9.bin
-rwxrwxrwx 1 root root 140K Oct 26 04:17 c931.bin
-rwxrwxrwx 1 root root 140K Oct 26 04:17 d2def806d493f.bin
-rwxrwxrwx 1 root root 140K Oct 26 04:17 db887b5440.bin
-rwxrwxrwx 1 root root 140K Oct 26 04:17 e75147c1b1b9406.bin
```

These `.bin` files were actually Windows executables written in Rust.

```
$ file 07c8b8cb6a9.bin
07c8b8cb6a9.bin: PE32+ executable for MS Windows 6.00 (console), x86-64, 5 sections

$ strings 07c8b8cb6a9.bin | grep rust
/rustc/4d91de4e48198da2e33413efdcd9cd2cc0c46688\library\core\src\str\pattern.rs
internal error: entered unreachable code/rustc/4d91de4e48198da2e33413efdcd9cd2cc0c46688\library\alloc\src\vec\mod.rs
/rustc/4d91de4e48198da2e33413efdcd9cd2cc0c46688\library\alloc\src\string.rs
/rustc/4d91de4e48198da2e33413efdcd9cd2cc0c46688\library\alloc\src\raw_vec.rs
__rust_end_short_backtrace__rust_begin_short_backtraces      [... omitted  frame ...]
/rustc/4d91de4e48198da2e33413efdcd9cd2cc0c46688\library\core\src\ops\function.rs
/rustc/4d91de4e48198da2e33413efdcd9cd2cc0c46688\library\core\src\str\pattern.rs
/rust/deps\rustc-demangle-0.1.24\src\legacy.rs
/rust/deps\rustc-demangle-0.1.24\src\v0.rs
.llvm./rust/deps\rustc-demangle-0.1.24\src\lib.rs
rust_panic
rust_panic
```

The `main` function in each of these was incredibly simple:

```C
__int64 sub_140001140()
{
  char v1[48]; // [rsp+28h] [rbp-30h] BYREF

  sub_140001070(v1, &off_14001A3B8);
  return sub_1400048E0(v1);
}
```

That was it. That's all they did. They loaded and printed a small string (a piece of the flag) from the exact same offset, every time.

![](./files/01%20-%20Puzzle%20Pieces%20Redux/01.png)

My teammate Urck originally solved this challenge using an unintended solution based on compilation timestamps. The intended solution is hinted at with the name of the cat in the challenge description: `Sasha`. This was a reference to SHA256 checksums.

```
$ sha256sum *.bin          
3a389838f872c04ee98b56b47b026c56e9e1bf9a791d33f07991d72c8eb20083  1a1962fc.bin
dec0721f3014e22cb1b121f065adaa6debf070c4dc86d4446cb3d6cb87300000  5eb6e6c8.bin
45951368223b60ee10f964785f96251fbfd2988af1c7cbb66bd27570ed000000  07c8b8cb6a9.bin
b8f23f0b8cb91161a8a757dc74d7f89d634f2bb50455233425105e44511150a5  7c8394d4b6b0.bin
7f0c897e241ac92d0c4c9ecf680cf8c570c72cc2a1a99ab50ce218c518fd0000  20a.bin
3bd187f44e284ff90986ed67104a53cff73fed14a55902a343a86a2108e7f000  64b.bin
598ef46397a9dbf5fe468543022f72a8014f7d0b9448058955f896914fa53f57  99fa27fd897.bin
79ec81fe08fded6518d296f50e9d9ef1524ea0c95d88b94b376834351ee53485  3511c0a625.bin
aecc3b8b3b871ac034c60ddb7c0698105bcf4c768603a0b4f64e3a1100000000  6676585.bin
27f1c4dad4c5e5bc3369adde78dc739121acd64a9549587f9f82a83b520f8704  a6ffddda.bin
ee1520fbe2b1dc1bb85321ddc602aa043f7728440e48524fb1b67e1b272822e0  a891a220.bin
0fd014cc10ca48f4c65e9be49914aa0c7e24a19c561801541185473e8a08f9a4  abc9.bin
d81c9372e8fe20e0917bfee218a8e9c78bdb4a41ad2f234b1d28865aa1eb7669  c931.bin
0b8b764a058b59bcb7868e3c402119b50ca02e6fb6eb98deec4821efcd82c29b  d2def806d493f.bin
016f23e8ac531cec3da547a0e0bc732b4ce96d26306c83b38ec14f7bd2a9e700  db887b5440.bin
3a9d1b97597e38008e13e2ba64667667bb1a6cdc43b905a826d91496b0000000  e75147c1b1b9406.bin
```

The valid flag pieces all had trailing zeroes in their SHA256 checksums. The first piece had one trailing zero, the second had two trailing zeroes, etc.

```Python
#!/usr/bin/env python3
import glob
import hashlib

def main():
    bins = []

    for item in glob.glob("*.bin"):
        checksum = hashlib.sha256(open(item, "rb").read()).hexdigest()
        
        if checksum[-1] != "0":
            continue
            
        bins.append([checksum[-1::-1], item])
        
    flag = []
        
    for item in sorted(bins):
        data = open(item[1], "rb").read()
        data = data[0x189B0:0x189B8]
        flag.append(data.decode().split("\n")[0])
        
    print("".join(flag[-1::-1]))

if __name__ == "__main__":
    main()
```

```
$ python solve.py
flag{be7a1e6817d85d549f8b5abfaf18ba02}
```

---

**Files:**
- [puzzle-pieces-redux.7z](./files//01%20-%20Puzzle%20Pieces%20Redux/puzzle-pieces-redux.7z)
- [solve.py](./files//01%20-%20Puzzle%20Pieces%20Redux/solve.py)