#!/usr/bin/env python
# -*- coding: utf-8 -*-

import re
import sys
import csv

if len(sys.argv) <= 1:
    print "missing file"
    sys.exit()

f = open(sys.argv[1], 'r')

inline = False
endline = False
headname = list()
multidot = re.compile(r"\.+")
multiws = re.compile(r"\s+")
multiwsplus = re.compile(r"\s{20,}")
numbers = None
mstart = mend = None
for line in f:
    line = line.strip(" \r\n")
    if not inline:
        mstart = re.search(r"^[0-9]{,3} ", line)
    if mstart is not None:
        if mstart.group() == line:
            continue
        headnum = int(mstart.group())
        inline = True
    if inline:
        mend = re.search(r"[0-9—]+$", line)
    if mend is not None:
        endline = True
    else:
        endline = False
    if endline and inline:
        if ".." in line:
            sepregexp = multidot
        else:
            sepregexp = multiwsplus
        numbers = sepregexp.split(line)[1].strip().replace(",","")
        numbers = multiws.sub(",",numbers).replace("—","")
        headname.append(sepregexp.split(line)[0].strip("0123456789 "))
        inline = False
    elif inline:
        headname.append(line.strip("0123456789 "))
    if numbers is not None:
        arr = numbers.split(",")
        #arr.insert(0,'"'+" ".join(headname)+'"')
        arr.insert(0,str(headnum))
        print ",".join(arr)
        headname = list()
        numbers = None
