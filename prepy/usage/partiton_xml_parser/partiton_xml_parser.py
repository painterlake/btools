#!/usr/bin/python3
# -*- coding: UTF-8 -*-
 
from xml.dom.minidom import parse
import xml.dom.minidom
import numpy as np
import sys
import os
 
import bo_pkg as bo

if len(sys.argv)!= 2:
   print("Failed: error args")
   exit()

# 1.解析xml
DOMTree = xml.dom.minidom.parse(sys.argv[1])
collection = DOMTree.documentElement
 
# 2. 在集合中获取所有partition
partitions = collection.getElementsByTagName("partition")
 
# 3. 提取每个partition name和对应size的详细信息，然后按照size的大小写入partition_size_*.txt文件
dict = {}
meta_real_size = 0

for partition in partitions:
   dict[partition.getAttribute("label")] = int(partition.getAttribute("size_in_kb"))
   meta_real_size = meta_real_size + int(partition.getAttribute("size_in_kb"))

partiton_size_file_name = "partiton_size_%s.txt" % os.path.split(sys.argv[1])[1][:-4]
bo.map_sort_write(dict, partiton_size_file_name)

print("\nSuccess: \n\t1. all sorted partiton-size information has been writted to %s" % partiton_size_file_name)
print("\t2. Meta real size: %d in KB or %d in MB or %d in GB" % (meta_real_size, meta_real_size/1024, meta_real_size/1024/1024))
print()