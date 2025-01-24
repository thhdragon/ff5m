#!/usr/bin/python

import socket
import sys

if len(sys.argv)!=2 and len(sys.argv)!=3:
    print("Use "+sys.argv[0]+" M99 [FILENAME]")
    exit(1)

if len(sys.argv)==2:
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.connect(("127.0.0.1", 8899))
        s.sendall(bytes("~"+sys.argv[1]+"\r\n","utf-8"))
        data = s.recv(1024)
        print('Received', repr(data))

if len(sys.argv)==3:
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.connect(("127.0.0.1", 8899))
        s.sendall(bytes("~M23 0:/user/"+sys.argv[2]+"\r\n","utf-8"))
        data = s.recv(1024)
        print('Received', repr(data))
