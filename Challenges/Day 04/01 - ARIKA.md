**Category:** Web  
**Author:** John Hammond

![](./files/01%20-%20ARIKA/01%20-%20ARIKA.png)

---

The challenge ZIP contained a very simple Flask application designed to execute whitelisted system commands.

```Python
import os, re
import subprocess
from flask import Flask, render_template, request, jsonify

app = Flask(__name__)

ALLOWLIST = ["leaks", "news", "contact", "help",
             "whoami", "date", "hostname", "clear"]

def run(cmd):
    try:
        proc = subprocess.run(["/bin/sh", "-c", cmd],capture_output=True,text=True,check=False)
        return proc.stdout, proc.stderr, proc.returncode
    except Exception as e:
        return "", f"error: {e}\n", 1

@app.get("/")
def index():
    return render_template("index.html")

@app.post("/")
def exec_command():
    data = request.get_json(silent=True) or {}
    command = data.get("command") or ""
    command = command.strip()
    if not command:
        return jsonify(ok=True, stdout="", stderr="", code=0)
    if command == "clear":
        return jsonify(ok=True, stdout="", stderr="", code=0, clear=True)
    if not any([ re.match(r"^%s$" % allowed, command, len(ALLOWLIST)) for allowed in ALLOWLIST]):
        return jsonify(ok=False, stdout="", stderr="error: Run 'help' to see valid commands.\n", code=2)
    
    stdout, stderr, code = run(command)
    return jsonify(ok=(code == 0), stdout=stdout, stderr=stderr, code=code)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.getenv("PORT", 5000)), debug=False)
```

There was a vulnerability in the call to `re.match`:

```Python
re.match(r"^%s$" % allowed, command, len(ALLOWLIST))
```

The result of `len(ALLOWLIST)` was `8` and was used for the `flags` argument. `8` corresponded to `re.MULTILINE`, which caused the regular expression to look for matches on every line. As long as the first line contained a valid command, the regular expression would match and command injection would occur.

![](./files/01%20-%20ARIKA/01.png)

Flag: **flag{eaec346846596f7976da7e1adb1f326d}**

---

**Files:**
- [arika.zip](./files//01%20-%20ARIKA/arika.zip)