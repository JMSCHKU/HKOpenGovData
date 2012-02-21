#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
from xml.dom import minidom

allowedtags = ["p", "span"]

if len(sys.argv) > 1:
    fname = sys.argv[1]
else:
    print "Missing file"
    sys.exit()

f = open(fname, "r")

txt = f.read()

try:
    dom = minidom.parseString("<xml>%s</xml>" % txt)
except Exception as e:
    print e
    print "Invalid File: %s " % fname
    sys.exit()

out = ""
count = 0
for page in dom.getElementsByTagName('page'):
    for child in page.childNodes:
	count += 1
	try:
	    if child.nodeType == child.TEXT_NODE:
		out += child.data.strip() + "\n"
	    elif child.localName is not None and child.localName.lower() in allowedtags and child.firstChild is not None:
		out += child.getAttribute("MCID") + " " + unicode(child.firstChild.data) + "\n"
	except:
	    continue
print out.encode("utf8")
