**Category:** Malware  
**Author**: John Hammond

![](./files/01%20-%20For%20Greatness/01%20-%20For%20Greatness.png)

---

The challenge ZIP contained a single file named `j.php` which itself contained a bunch of obfuscated PHP code with a big blob of data in the middle. The data blob was octal-escaped ASCII which revealed a base64 blob. I wrote a Python script to extract and decode it.

```Python
#!/usr/bin/env python3
import re
import base64

def main():
    data = open("j.php").read()
    data = data.split('$FRczk = "')[1].split('"')[0]
    data = data.encode("utf-8").decode("unicode_escape")
    data = base64.b64decode(data)
    
    with open("stage2.bin", "wb") as fout:
        fout.write(data)
    
if __name__ == "__main__":
    main()
```

The data didn't have any obvious magic bytes, but the Linux `file` command identified it as zlib compressed data:

```
$ file stage2.bin
stage2.bin: zlib compressed data
```

Updating my script to account for this revealed a second layer of obfuscated PHP. I wrote another script to carve that out and decode it, resulting in `stage3.php`. This final stage was an unobfuscated PHP script containing the following function and a backwards flag:

```PHP
public function mailTo($add,$cont){
	$subject='++++Office Email From Greatness+++++';
	$headers='Content-type: text/html; charset=UTF-8' . "\r\nFrom: Greatness <ghost+}f7113307018770d52d4f94fec013197f{galf@greatness.com>" . "\r\n";
	@mail($add,$subject,$cont,$headers);
}
```

```
>>> print("}f7113307018770d52d4f94fec013197f{galf"[-1::-1])
flag{f791310cef49f4d25d0778107033117f}
```

Flag: **flag{f791310cef49f4d25d0778107033117f}**

---

**Files:**
- [for_greatness.zip](./files//01%20-%20For%20Greatness/for_greatness.zip)
- [j.php](./files//01%20-%20For%20Greatness/j.php)
- [j.py](./files//01%20-%20For%20Greatness/j.py)
- [stage2.bin](./files//01%20-%20For%20Greatness/stage2.bin)
- [stage2.php](./files//01%20-%20For%20Greatness/stage2.php)
- [stage2.py](./files//01%20-%20For%20Greatness/stage2.py)
- [stage3.php](./files//01%20-%20For%20Greatness/stage3.php)