**Category**: Miscellaneous  
**Author**: John Hammond

![](./files/01%20-%20vx-underground/01%20-%20vx-underground.png)

---

The challenge ZIP was huge and contained:

- An encrypted `flag.zip` file.
- A picture of a cat named `prime_mod.jpg`.
- A `Cat Archive` directory containing **457** cat JPEGs.

Examining the `prime_mod.jpg` file with `exiftool` revealed the following:

```
$ exiftool prime_mod.jpg
ExifTool Version Number         : 13.25
File Name                       : prime_mod.jpg
Directory                       : .
File Size                       : 43 kB
File Modification Date/Time     : 2025:09:21 17:31:54-04:00
File Access Date/Time           : 2025:10:27 21:12:28-04:00
File Inode Change Date/Time     : 2025:09:21 17:31:54-04:00
File Permissions                : -rwxrwxrwx
File Type                       : JPEG
File Type Extension             : jpg
MIME Type                       : image/jpeg
JFIF Version                    : 1.01
Resolution Unit                 : None
X Resolution                    : 1
Y Resolution                    : 1
Exif Byte Order                 : Big-endian (Motorola, MM)
User Comment                    : Prime Modulus: 010000000000000000000000000000000000000000000000000000000000000129
Image Width                     : 400
Image Height                    : 400
Encoding Process                : Baseline DCT, Huffman coding
Bits Per Sample                 : 8
Color Components                : 3
Y Cb Cr Sub Sampling            : YCbCr4:2:0 (2 2)
Image Size                      : 400x400
Megapixels                      : 0.160
```

This combined with the fact that the challenge prompt mentioned "secret sharing" strongly suggested to me that I was looking at an implementation of [Shamir's secret sharing](https://en.wikipedia.org/wiki/Shamir%27s_secret_sharing) algorithm. Taking a look at the EXIF data for the other pictures further added to that suspicion:

```
$ exiftool cats/* | grep 'User Comment'
User Comment                    : 253-6ba02f81b0c38473b0442d0ebc46f4a8223edead6d164103fbcdeb10ea414e76
User Comment                    : 145-2d9ab042a4bf21369ed72897366204feff54359585275a09ab64975c43304962
User Comment                    : 415-0551477bacb1ac94a91466ffa3d96e67940afde60ff0dc79d928609a55fccfe2
...
```

Those certainly looked like share indexes and values. I extracted everything like so:

```
$ exiftool prime_mod.jpg | awk '/^User Comment/{ print $6 }' > prime.txt
$ exiftool cats/* | awk '/^User Comment/{print $4}' > shares.txt
```

I then repurposed a Python script I had written for a similar challenge on HackTheBox:

```Python
#!/usr/bin/env python3
from Crypto.Util.number import long_to_bytes

def modinv(a, m):
    return pow(a, -1, m)

def lagrange_at_zero(shares, prime):
    secret = 0
    for i, (xi, yi) in enumerate(shares):
        num = den = 1
        for j, (xj, _) in enumerate(shares):
            if i != j:
                num = (num * (-xj)) % prime
                den = (den * (xi - xj)) % prime
        secret = (secret + yi * num * modinv(den, prime)) % prime
    return secret
    
def main():
    prime = eval("0x%s" % open("prime.txt").read())
    
    shares = [o.strip().split("-") for o in open("shares.txt").readlines()]
    
    for n in range(len(shares)):
        shares[n][0] = int(shares[n][0])
        shares[n][1] = eval("0x%s" % shares[n][1])
        
    print(long_to_bytes(lagrange_at_zero(shares, prime)).decode())
    
if __name__ == "__main__":
    main()
```

```
$ python shares.py
*ZIP password: FApekJ!yJ69YajWs

$ 7z e flag.zip

7-Zip 24.09 (x64) : Copyright (c) 1999-2024 Igor Pavlov : 2024-11-29
 64-bit locale=en_US.UTF-8 Threads:128 OPEN_MAX:1024, ASM

Scanning the drive for archives:
1 file, 454 bytes (1 KiB)

Extracting archive: flag.zip
--
Path = flag.zip
Type = zip
Physical Size = 454

    
Enter password (will not be echoed):
Everything is Ok

Size:       34216
Compressed: 454
```

I was expecting a flag, but what I got was `cute-kitty-noises.txt`.

```
$ cat cute-kitty-noises.txt
MeowMeow;MeowMeowMeowMeowMeowMeowMeowMeowMeowMeowMeowMeowMeowMeowMeowMeowMeow ...
```

The first thing I thought of was maybe this was some kind of esoteric programming language, so I Googled. Sure enough, [it was](https://github.com/wixette/meowlang). I submitted the contents of `cute-kitty-noises.txt` to https://wixette.github.io/meowlang/ and got a bunch of lines of cat emojis.

Every line had a different number of cats and those counts always fell within the ASCII character range.

```
$ python -c 'print("".join([chr(len(o.strip())) for o in open("meow.txt").readlines()]))'
malware is illegal and for nerds
cats are cool and badass
flag{35dcba13033459ca799ae2d990d33dd3}
```

Flag: **flag{35dcba13033459ca799ae2d990d33dd3}**

---

**Files:**
- [cute-kitty-noises.txt](./files//01%20-%20vx-underground/cute-kitty-noises.txt)
- [flag.zip](./files//01%20-%20vx-underground/flag.zip)
- [hash.txt](./files//01%20-%20vx-underground/hash.txt)
- [meow.txt](./files//01%20-%20vx-underground/meow.txt)
- [prime.txt](./files//01%20-%20vx-underground/prime.txt)
- [prime_mod.jpg](./files//01%20-%20vx-underground/prime_mod.jpg)
- [shares.py](./files//01%20-%20vx-underground/shares.py)
- [shares.txt](./files//01%20-%20vx-underground/shares.txt)
- [vx-underground.zip](./files//01%20-%20vx-underground/vx-underground.zip)