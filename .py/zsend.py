#!/usr/bin/python

import socket
import sys

if len(sys.argv) != 2 and len(sys.argv) != 3:
    print(f"Use {sys.argv[0]} M99 [FILENAME]")
    exit(1)


def send(data):
    with socket.socket() as s:
        s.connect(("127.0.0.1", 8899))
        s.settimeout(30)

        s.sendall(data.encode())

        data = s.recv(1024)
        print('Response:', data.decode())


if len(sys.argv) == 2:
    send(f"~{sys.argv[1]}\r\n")

if len(sys.argv) == 3:
    send(f"~M23 0:/user/{sys.argv[2]}\r\n")
