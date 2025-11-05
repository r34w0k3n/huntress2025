**Category**: OSINT  
**Author**: Brady

![](./files/01%20-%20Follow%20the%20Money/01%20-%20Follow%20the%20Money.png)

---

The challenge ZIP contained a series of email files:

- `email 1 - FTM.eml`
- `email 2 - FTM.eml`
- `email 3 - FTM.eml`
- `email 4 - FTM.eml`
- `email 5 - FTM.eml`

The first email contained a link to https://evergatetitle.netlify.app/ and read:

```
Hey Evelyn! 

We at Evergate Title are excited to kick off our new partnership with Harbor Line Bank. We look forward to facilitating seamless title and escrow services for your clients.

To make our collaboration as efficient as possible, please note that all funds transfers and disbursement requests related to our joint escrow transactions can be easily initiated directly through the [Evergate Title partner portal] on our website. This streamlined digital process ensures faster, more secure handling of closing funds.

In the meantime, please don't hesitate to reach out to us if you require immediate assistance, a guided walkthrough of the transfer process, or need to schedule a brief training session for your team.

We are committed to making this transition smooth and successful.

Best regards,
Justin Case
```

The fifth email contained a link to https://evergatetltle.netlify.app/ and read:

```
Good Day Evelyn, 

I see you sent over the payment. Unfortunately it didnt go through. Kindly give it another try. Please continue to use the link in my signature.

Thank you very much,
Justin Case

[Evergate Title Transfer]
```

The lowercase `i` in the first link had been swapped for a lowercase `l` in the second. Unlike on the legitimate site, when you used the `Transfer Closing Funds` feature on the fake site, you would see the following popup:

![](./files/01%20-%20Follow%20the%20Money/01.png)

```
$ echo aHR0cHM6Ly9uMHRydXN0eC1ibG9nLm5ldGxpZnkuYXBwLw== | base64 -d
https://n0trustx-blog.netlify.app/
```

There wasn't much at all on https://n0trustx-blog.netlify.app/ besides a link to a [GitHub](https://github.com/N0TrustX) which contained a repository named [Spectre](https://github.com/N0TrustX/Spectre), which held the [HTML page](https://raw.githubusercontent.com/N0TrustX/Spectre/refs/heads/main/spectre.html) for something called the `Spectre Exfil Tool`. Contained within the HTML was this:

```HTML
...
<!-- This div will hold the DECODED object -->
<div id="decodedPayloadContainer" class="bg-gray-900 p-9 rounded-lg text-2xl font-bold text-yellow-400">
	<!-- The decoded object will appear here -->
</div>
<!-- The Base64 encoded object is stored here, hidden from view -->
<div id="encodedPayload" class="hidden">ZmxhZ3trbDF6a2xqaTJkeWNxZWRqNmVmNnltbHJzZjE4MGQwZn0=</div>
<button id="closePayloadBtn" class="mt-8 action-button font-bold py-2 px-6 rounded-lg">Close</button>
...
```

```
$ echo ZmxhZ3trbDF6a2xqaTJkeWNxZWRqNmVmNnltbHJzZjE4MGQwZn0= | base64 -d
flag{kl1zklji2dycqedj6ef6ymlrsf180d0f}
```

Flag: **flag{kl1zklji2dycqedj6ef6ymlrsf180d0f}**

---

**Files:**
- [email 1 - FTM.eml](./files//01%20-%20Follow%20the%20Money/email%201%20-%20FTM.eml)
- [email 2 - FTM.eml](./files//01%20-%20Follow%20the%20Money/email%202%20-%20FTM.eml)
- [email 3 - FTM.eml](./files//01%20-%20Follow%20the%20Money/email%203%20-%20FTM.eml)
- [email 4 - FTM.eml](./files//01%20-%20Follow%20the%20Money/email%204%20-%20FTM.eml)
- [email 5 - FTM.eml](./files//01%20-%20Follow%20the%20Money/email%205%20-%20FTM.eml)
- [follow_the_money.zip](./files//01%20-%20Follow%20the%20Money/follow_the_money.zip)