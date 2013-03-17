#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import urllib
import urllib2
import json

if len(sys.argv) > 2:
    tableid = sys.argv[1]
    csvfile = sys.argv[2]
else:
    print "ftimport.py [tableid] [csv file]"
    sys.exit()

method = "POST"

url = "https://www.googleapis.com/upload/fusiontables/v1/tables/" + tableid + "/import"

f_token = open("/home/csam/google.fusiontables.token", "r")
token_txt = f_token.read()
token = json.loads(token_txt)

f_csv = open(csvfile, "r")
csv_txt = f_csv.read()

headers = { "Authorization": token["token_type"] + " " + token["access_token"], "Content-type": "application/octet-stream" }
#headers = { "Authorization": token["token_type"] + " " + token["access_token"], "Content-type": "application/x-www-form-urlencoded", "Accept": "text/plain" }

req = urllib2.Request(url, data=csv_txt, headers=headers)
req.get_method = lambda: method
try:
    resp = urllib2.urlopen(req, timeout=120)
    resp_txt = resp.read()
    #print resp_txt
except urllib2.HTTPError as e:
    #print e
    pass
