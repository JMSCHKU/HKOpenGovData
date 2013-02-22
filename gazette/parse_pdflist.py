#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import re
import csv
import datetime
import pprint
import xml.etree.ElementTree as ET

if len(sys.argv) <= 1:
    sys.exit()

tree = ET.parse(sys.argv[1])
root = tree.getroot()

fields = ["date", "vol", "no", "extra", "type", "section", "rev", "notice_no", "subject", "dept", "deptemail", "officer", "link"]
textfields = ["section", "subject", "dept", "officer"]

pdfs = list()

# Parse header infos
head = root[0].text
date_re = re.search(r"\d{2}/\d{2}/\d{4}", head)
if date_re is not None:
    d = datetime.datetime.strptime(date_re.group(0), "%d/%m/%Y")
    d = d.strftime("%Y-%m-%d")
no_re = re.search(r"No\. (\d+)", head)
if no_re is not None:
    no = no_re.group(1)
vol_re = re.search(r"Vol\. (\d+)", head)
if vol_re is not None:
    vol = vol_re.group(1)
extra_re = re.search(r"Gazette Extraordinary", head)
if extra_re is not None:
    extra = 1
else:
    extra = 0

# Parse revision date
if len(root) > 2:
    rev = root[2].text
    rev = rev.split(" = ")[1].split('"')[1]
    drev = datetime.datetime.strptime(rev, "%d %b %Y")
    rev = drev.strftime("%Y-%m-%d")
else:
    rev = None

table = root[1]
if table.tag == "tbody":
    table = table[0]
isheader = True
for tr in table:
    if isheader:
        isheader = False
        continue
    if len(tr) <= 1: # sub-header
        section = tr[0].text
        continue
    row = dict()
    row["date"] = d
    row["vol"] = vol
    row["no"] = no
    row["extra"] = extra
    row["section"] = section
    row["rev"] = rev
    #row["desc"] = tr[0].text
    try:
        row["notice_no"] = int(tr[0][0].text)
    except:
        if tr[0][0].text == "--":
            row["notice_no"] = None
        else:
            row["notice_no"] = tr[0][0].text
    row["subject"] = tr[1][0].text
    if len(tr) > 2:
        if len(tr[2]) > 0:
            row["dept"] = tr[2][0].text
            row["deptemail"] = tr[2][0].get("href").split(":")[1]
        else:
            row["dept"] = tr[2].text
            row["deptemail"] = None
    else:
        row["dept"] = None
        row["deptemail"] = None
    if len(tr) > 3:
        if len(tr[3]) > 0:
            row["officer"] = tr[3][0].text
        else:
            row["officer"] = tr[3].text
    else:
        row["officer"] = None
    row["link"] = tr[0][0].get("href")
    for a in textfields:
        if row[a] is not None:
            row[a] = row[a].encode("utf8").strip()
    pdfs.append(row)

cw = csv.DictWriter(sys.stdout, fields)

for r in pdfs:
    cw.writerow(r)
