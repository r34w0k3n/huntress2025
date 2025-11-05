**Category**: Miscellaneous  
**Author**: Tim Sword

![](./files/01%20-%20Angler/01%20-%20Angler.png)

---

Attached is a file named `scribbles.dat`.

The beginning of this challenge was really annoying. Overall it was decent and I learned things, but the first part was basically, "Just guess, bro!"

You see, if you decode the above bytes you'll get the word `Blowfish`. If you then *simply* guess that this is the key AND the IV for the Blowfish cipher, well then you're a whopping 1/5th of the way there! Now that you've decrypted the data with Blowfish, you'll be left with a bunch of bits in nice, little byte sized groups. Convert them to their decimal values and then to ASCII characters! You now have what looks like hexadecimal, and it is! Except it's not! It's *backwards*! And if you would but simply be intelligent enough to guess that you should reverse it, you would now be able to decode it and receive a base64 string to decode!

Anyway, this was the CyberChef recipe to unscramble it:

```
Blowfish_Decrypt({'option':'Hex','string':'42 6c 6f 77 66 69 73 68'},{'option':'Hex','string':'42 6c 6f 77 66 69 73 68'},'CBC','Hex','Raw')
From_Binary('Space',8)
Reverse('Character')
From_Hex('Auto')
From_Base64('A-Za-z0-9+/=',true,false)
```

And this was the resulting plaintext:

```
phisher@4rhdc6.onmicrosoft.com:PhishingAllTheTime19273!!

My sea is made of data, my shore a glowing screen, I cast my line with careful code, in a vast and global scene.
My lure is not a worm or fly, but a name you trust, a prize, My hook is hid within a link, disguised before your eyes.
I do not fish for flesh or fin, but for a private key, reeling in the secrets you mistakenly give to me.
Send to that which is found within the above, to the destination you have yet to reveal, and the secret you seek will reveal.
```

---

There were six flags in total. Flags 1-5 came from [exported Entra data](https://github.com/microsoft/EntraExporter). The final flag came from sending an email to a specific account.

I did this half in PowerShell, half in Bash:

```PowerShell
PS D:\> Install-Module EntraExporter
PS D:\> Connect-MgGraph -nowelcome -Scopes 'Directory.Read.All' , 'User.Read.All'
PS D:\> Export-Entra -Path '.' -All
```

```
$ find . -name *.json -type f | xargs iconv -f UTF-16 -t UTF-8 $1 | grep 'flag{'                    
    "displayName":  "flag{mczxals2amxc}",
    "usernameHintText":  "flag{928nzlasdu2}",
    "notes":  "flag{2naxajsmcwijdm}",
    "notes":  "flag{3mcnzxjaslwinca}",
    "companyName":  "flag{02818nccnasd}",
```

- Submit the bonus flag that ends with the character `2` below: **flag{928nzlasdu2}**
- Submit the bonus flag that ends with the character `d` below: **flag{02818nccnasd}**
- Submit the bonus flag that ends with the character `a` below: **flag{3mcnzxjaslwinca}**
- Submit the bonus flag that ends with the character `m` below: **flag{2naxajsmcwijdm}**
- Submit the bonus flag that ends with the character `c` below: **flag{mczxals2amxc}**

```
What is the FINAL flag? This flag is unlike the others and ends with a `?` character.
```

This was found by sending an email with the title/subject `Blowfish` to `nattyp@51tjxh.onmicrosoft.com`. This email address could also be carved out from the exported Entra data. It was the obvious choice since the entire challenge was a reference to a video game character, [Nat Pagle](https://wowpedia.fandom.com/wiki/Nat_Pagle).

![](./files/01%20-%20Angler/flag_final.png)

Flag: **flag{didsomeonesay..?}**

---

**Files:**
- [entra_export.zip](./files//01%20-%20Angler/entra_export.zip)
- [scribbles.dat](./files//01%20-%20Angler/scribbles.dat)