**Category**: Forensics  
**Author:** John Hammond

![](./files/01%20-%20Darcy/01%20-%20Darcy.png)

---

Extracting the challenge archive gave me a few hundred files in a directory structure that reminded me of git:

```
$ ls -lha _darcs                       
total 622K
drwxrwxrwx 1 root root 4.0K Oct 20 09:05 .
drwxrwxrwx 1 root root  40K Oct 20 09:06 ..
-rwxrwxrwx 1 root root   15 Oct 20 09:05 format
-rwxrwxrwx 1 root root  95K Oct 20 09:05 hashed_inventory
-rwxrwxrwx 1 root root   72 Oct 20 09:05 index
-rwxrwxrwx 1 root root   72 Oct 20 09:05 index.old
drwxrwxrwx 1 root root 160K Oct 20 09:05 inventories
drwxrwxrwx 1 root root 160K Oct 20 09:05 patches
drwxrwxrwx 1 root root    0 Oct 20 09:05 prefs
drwxrwxrwx 1 root root 160K Oct 20 09:05 pristine.hashed
-rwxrwxrwx 1 root root   14 Oct 20 09:05 rebase
-rwxrwxrwx 1 root root   74 Oct 20 09:05 tentative_pristine

$ ls -lha .     
total 81M
drwxrwxrwx 1 root root  40K Oct 20 09:06 .
drwxrwxrwx 1 root root 8.0K Oct 28 17:24 ..
-rwxrwxrwx 1 root root   65 Oct 20 09:05 00413a24ab3f932d
-rwxrwxrwx 1 root root   65 Oct 20 09:05 00871c0644d141de
-rwxrwxrwx 1 root root   65 Oct 20 09:05 0200211f20a671f8
-rwxrwxrwx 1 root root   65 Oct 20 09:05 03bd86ff49259ecd
-rwxrwxrwx 1 root root   65 Oct 20 09:05 04d12273f8f20ffc
-rwxrwxrwx 1 root root   65 Oct 20 09:05 04d57686cd1c4a05
-rwxrwxrwx 1 root root   65 Oct 20 09:05 0569d29365e77449
-rwxrwxrwx 1 root root   65 Oct 20 09:05 0644e12a526120b9
...
```

Solve method number one was to download the appropriate [darcs](https://darcs.net/) binary and search the logs that way:

```
D:\Virtual\Shared\huntress\darcy>.\darcs.exe log -p flag
patch b7b8767c2e09faf049a37d74315325f34e9d0fd8
Author: ctf@ctf.huntress.com
Date:   Tue Sep 30 02:18:27 Eastern Daylight Time 2025
  * routine update; details: flag{a0c1e852e1281d134f0ac2b8615183a3}
```

Solve method number two was to simply do a recursive `grep`:

```
$ grep -nri 'flag' .
./_darcs/hashed_inventory:1202:[routine update; details: flag{a0c1e852e1281d134f0ac2b8615183a3}
./_darcs/prefs/boring:3:# out during `darcs add`, or when the `--look-for-adds` flag is passed
```

Flag: **flag{a0c1e852e1281d134f0ac2b8615183a3}**

---

**Files:**
- [darcy.tar.gz](./files//01%20-%20Darcy/darcy.tar.gz)