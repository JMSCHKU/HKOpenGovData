#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import pg
import json
import mypass
import types

if len(sys.argv) < 1:
    print "Missing table name"
    sys.exit()

tablename = sys.argv[1]
pgconn = mypass.getConn()
r = pgconn.query("SELECT * FROM hkcensus.%s LIMIT 1" % tablename).dictresult()

out = {
    "kind": "fusiontables#table",
    "name": tablename,
    "columns": [
    ],
    "description": "",
    "isExportable": False,
    "attribution": "JMSC, HKU",
    "attributionLink": "http://jmsc.hku.hk/blogs/ricecooker/"
}
i = 0
for k in r[0].keys():
    c = r[0][k]
    col = { "columnId": i, "name": k, "type": "NUMBER" }
    if type(c) is types.StringType:
	col["type"] = "STRING"
    i += 1
    out["columns"].append(col)
pnt = { "columnId": i+1, "name": "point", "type": "LOCATION" }
out["columns"].append(pnt)
bnd = { "columnId": i+2, "name": "boundary", "type": "LOCATION" }
out["columns"].append(bnd)

print json.dumps(out)
