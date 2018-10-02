
import sys
import os

import re

stdinput = sys.stdin.readlines()

regex = stdinput[0]
strings = stdinput[1:]

def checkstring(string,pattern):
    string = string.strip()
    pattern = pattern.strip()
    res = re.search(pattern,string) is not None
    return(res)

res = [str(checkstring(s,regex))+'\n' for s in strings]
for l in res:
    sys.stdout.write(l)
