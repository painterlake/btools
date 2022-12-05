#
# @file bo_string.py
#

def map_sort_write(dict, filename):
   list = sorted(dict.items(),key=lambda x:x[1],reverse=True)
   str1 = ""
   for i in list:
      str1 = str1 + i[0] + '\t\t' + str(i[1]) + '\n'
   file=open(filename,'w')
   file.write(str1)
   file.close()