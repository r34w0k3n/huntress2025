**Category**: Malware  
**Author**: Adam Rice

![](./files/01%20-%20Lizard/01%20-%20Lizard.png)

---

![](./files/01%20-%20Lizard/01.gif)

This challenge was hilarious. While reversing it I accidentally detonated a snippet from one of the stages on my Windows host. I ended up fighting back popups and TTS voices. Only hours later when I was doing something else did I realize my wallpaper had changed to a giant lizard eye. Sadly I forgot to screenshot that.

Visiting http://biglizardlover.com/gecko in a normal browser would display an error:

![](./files/01%20-%20Lizard/02.png)

Spoofing your User-Agent header to match that of PowerShell would allow you to download stage one of about **twelve**.

I solved this challenge entirely by hand, carefully (and then that **one time** not-so-carefully) copy-pasting strings into my PowerShell console to let them evaluate and reveal pieces of the next stage. Once I reached the third stage, I found this:

```PowerShell
("{9}{16}{11}{4}{10}{12}{8}{14}{13}{5}{0}{15}{3}{1}{7}{6}{2}" -f 'hion','n','l',' u',' = o','s','uerebe','iq','ttest ','fl','b','e','jec','sumerfa','+ con',' +','agvalu')
```

The above evaluated to the following:

```
flagvalue = objecttest + consumerfashion + uniquerebel
```

Then at the very bottom of that stage, the obfuscated `consumerfashion` variable was found:

```PowerShell
${COns`UMeRf`A`S`HIOn} = ("{2}{1}{6}{3}{0}{5}{4}"-f '3T','B','WXp','Gt','PQ==','Wpn','ME16UmtOV')
```

This was the first piece of the base64 encoded flag. The rest of the challenge was pretty much a repeat of this; carefully carving out strings I ~~knew~~ *thought* were safe to evaluate, (almost) avoiding every obfuscated `Invoke-Expression` statement, etc. There are ways to automate this, but doing it manually was incredibly fun.

The `objecttest` piece was found at the bottom of what I named `stage07.ps1`:

```PowerShell
$objectTest = "Wm14aFozczNOak0wTWpZNVlXVmhPRGs9"
```

The `uniquerebel` piece was found at the bottom of what I named `stage11.ps1`:

```PowerShell
$UniqueRebel = "TWpVeU9UWXlORGN3ZlE9PQ=="
```

With all three pieces in hand, it was time to reconstruct the flag:

```Python
#!/usr/bin/env python3
import base64

def main():
    segments = [
        "Wm14aFozczNOak0wTWpZNVlXVmhPRGs9",
        "WXpBME16UmtOVGt3TWpnPQ==",
        "TWpVeU9UWXlORGN3ZlE9PQ=="
    ]

    flag = ""

    for item in segments:
        # Not a typo. They're double base64 encoded.
        item = base64.b64decode(item)
        item = base64.b64decode(item)
        flag += item.decode()

    print(flag)
    
if __name__ == "__main__":
    main()
```

```
$ python solve.py
flag{7634269aea89c0434d59028252962470}
```

Flag: **flag{7634269aea89c0434d59028252962470}**

---

**Files:**
- [gecko.ps1](./files//01%20-%20Lizard/gecko.ps1)
- [gecko.zip](./files//01%20-%20Lizard/gecko.zip)
- [solve.py](./files//01%20-%20Lizard/solve.py)
- [stage02.ps1](./files//01%20-%20Lizard/stage02.ps1)
- [stage03.ps1](./files//01%20-%20Lizard/stage03.ps1)
- [stage04.ps1](./files//01%20-%20Lizard/stage04.ps1)
- [stage05.ps1](./files//01%20-%20Lizard/stage05.ps1)
- [stage06.ps1](./files//01%20-%20Lizard/stage06.ps1)
- [stage07.ps1](./files//01%20-%20Lizard/stage07.ps1)
- [stage08.ps1](./files//01%20-%20Lizard/stage08.ps1)
- [stage09.ps1](./files//01%20-%20Lizard/stage09.ps1)
- [stage10.ps1](./files//01%20-%20Lizard/stage10.ps1)
- [stage11.ps1](./files//01%20-%20Lizard/stage11.ps1)