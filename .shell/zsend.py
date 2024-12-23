#!/usr/bin/python

import socket
import sys

if len(sys.argv)!=2:
    print("Use "+sys.argv[0]+" M99")
    exit(1)

with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    s.connect(("127.0.0.1", 8899))
    s.sendall(bytes("~"+sys.argv[1]+"\r\n","utf-8"))
    data = s.recv(1024)
    print('Received', repr(data))
    s.close()
