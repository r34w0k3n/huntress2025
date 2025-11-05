**Category:** Malware  
**Author:** John Hammond

![](./files/02%20-%20Spaghetti/02%20-%20Spaghetti.png)

---

**01 - MainFileSettings**

The challenge ZIP contained two files: `AYGIW.tmp` and `spaghetti`.

I ended up backtracking to get this flag because presumably the main file would be the PowerShell malware named `spaghetti`, so naturally I started there. However, *apparently* the "main file" was instead the `AYGIW.tmp` file that `spaghetti` loaded, as seen here:

```PowerShell
$currentDirectory = Get-Location
$fileName = "AYGIW.tmp"
$filePath = Join-Path -Path $currentDirectory -ChildPath $fileName
$MainFileSettings = Get-Content -Path $filePath
```

A bit further down in `spaghetti`:

```PowerShell
[byte[]]$WULC4 = HombaAmigo($MainFileSettings.replace('WT','00'))
```

`AYGIW.tmp` looked like a bunch of hexadecimal with `WT` mixed in. I decoded and dumped it using Python:

``` Python
>>> with open("MainSettingsFile.bin", "wb") as fout:
...     fout.write(bytes.fromhex(open("AYGIW.tmp").read().replace("WT","00")))
...
989185
```

It turned out to be a Windows executable, but reverse engineering it wasn't even necessary.

```
$ strings MainSettingsFile.bin | grep flag
flag{39544d3b5374ebf7d39b8c260fc4afd8}
```

Flag: **flag{39544d3b5374ebf7d39b8c260fc4afd8}**

---

**02 - My Fourth Oasis**

The `spaghetti` file was aptly named and filled with 4,000 lines PowerShell comments and `Write-Host` commands that output random integers. Buried in the middle of all that were two huge strings that got their elements swapped out before being fed into a decoding function, like so:

```PowerShell
$MyOasis4 = (FonatozQZ("~%%%~~%%~%%%~%~~~%%~~~~%~ --SNIP--".Replace('~','0').Replace('%','1')))
```

```PowerShell
$TDefo = (FonatozQZ("~%~~~~~%~%%~~%~~~%%~~%~~~~%~ --SNIP--".Replace('~','0').Replace('%','1')))
```

This was clearly forming strings of binary. The decoding function further confirmed this:

```PowerShell
Function FonatozQZ($monoTXtak) {
    $byTZlist = [System.Collections.Generic.List[Byte]]::new()
    for ($i = 0; $i -lt $monoTXtak.Length; $i +=8) {
        $byTZlist.Add([Convert]::ToByte([String] $monoTXtak.Substring($i, 8), 2))
    }
    return [System.Text.Encoding]::ASCII.GetString($byTZlist.ToArray())
}
```

After being decoded, the strings were piped into an obfuscated `Invoke-Expression`. I hacked up a Python script to decode and dump them.

```Python
#!/usr/bin/env python3
import re

def main():
    data = [o.strip() for o in open("spaghetti").readlines()]

    for line in data:
        if "$MyOasis4" in line:
            bin = line.split('"')[1].replace("~", "0").replace("%", "1")
            bin = "".join([chr(int(bin[n:n+8], 2)) for n in range(0, len(bin), 8)])
            
            with open("MyOasis4.ps1", "w") as fout:
                fout.write(bin)
            
            break

    for line in data:
        if "$TDefo" in line:
            bin = line.split('"')[1].replace("~", "0").replace("%", "1")
            bin = "".join([chr(int(bin[n:n+8], 2)) for n in range(0, len(bin), 8)])
            
            with open("TDefo.ps1", "w") as fout:
                fout.write(bin)
                
            break
            
if __name__ == "__main__":
    main()
```

The `MyOasis4.ps1` script implemented an AMSI bypass and included these three lines:

```PowerShell
$BBWHVWQ = [ZQCUW]::LoadLibrary("$([SYstem.Net.wEBUtIlITy]::HTmldecoDE('&#97;&#109;&#115;&#105;&#46;&#100;&#108;&#108;'))")
$XPYMWR = [ZQCUW]::GetProcAddress($BBWHVWQ, "$([systeM.neT.webUtility]::HtMldECoDE('&#65;&#109;&#115;&#105;&#83;&#99;&#97;&#110;&#66;&#117;&#102;&#102;&#101;&#114;'))")
# $XPYMWR = [ZQCUW]::GetProcAddress($BBWHVWQ, "$([systeM.neT.webUtility]::HtMldECoDE('&#102;&#108;&#97;&#103;&#123;&#98;&#51;&#49;&#51;&#55;&#57;&#52;&#100;&#99;&#101;&#102;&#51;&#51;&#53;&#100;&#97;&#54;&#50;&#48;&#54;&#100;&#53;&#52;&#97;&#102;&#56;&#49;&#98;&#54;&#50;&#48;&#51;&#125;'))")
```

The first two lines were used for the AMSI bypass, while the third contained the flag.

```
>>> import html
>>> html.unescape("&#102;&#108;&#97;&#103;&#123;&#98;&#51;&#49;&#51;&#55;&#57;&#52;&#100;&#99;&#101;&#102;&#51;&#51;&#53;&#100;&#97;&#54;&#50;&#48;&#54;&#100;&#53;&#52;&#97;&#102;&#56;&#49;&#98;&#54;&#50;&#48;&#51;&#125;")
'flag{b313794dcef335da6206d54af81b6203}'
```

Flag: **flag{b313794dcef335da6206d54af81b6203}**

---

**03 - MEMEMAN**

This flag was inside the second script from above, `TDefo.ps1`, which executed commands for persistence. One in particular stood out:

```
# Add-MpPreference -ExclusionExtension "flag{60814731f508781b9a5f8636c817af9d}"
```

Flag: **flag{60814731f508781b9a5f8636c817af9d}**

---

**Files:**
- [AYGIW.tmp](./files//02%20-%20Spaghetti/AYGIW.tmp)
- [MainSettingsFile.bin](./files//02%20-%20Spaghetti/MainSettingsFile.bin)
- [MyOasis4.ps1](./files//02%20-%20Spaghetti/MyOasis4.ps1)
- [spaghetti](./files//02%20-%20Spaghetti/spaghetti)
- [spaghetti.py](./files//02%20-%20Spaghetti/spaghetti.py)
- [spaghetti.zip](./files//02%20-%20Spaghetti/spaghetti.zip)
- [TDefo.ps1](./files//02%20-%20Spaghetti/TDefo.ps1)