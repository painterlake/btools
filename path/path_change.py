#!/usr/bin/python3
# -*- coding: UTF-8 -*-
 
from sys import argv
import re
import socket

if len(argv) <1:
    print ("usage: python path_change.py <your path>")

orign_path = argv[1]
hostname = socket.gethostname()

if(orign_path[0] == "/"):
    final_path = orign_path.replace("/home/bozhang/share","Z:")
    final_path = final_path.replace("/","\\")
elif(orign_path[0] == "Z"):
    final_path = orign_path.replace('\\','/')
    final_path = final_path.replace("Z:","/home/bozhang/share")
else:
    print()
    print("===========================Failed==============================")
    print("wrong orign path")
    print("usage: python path_change.py <your path>")
    print("your path must be included by 双引号")
    print("===========================Failed==============================")
    print()
    exit()

print
print("===========================success============================")
print(final_path)

print("===========================success============================")
print