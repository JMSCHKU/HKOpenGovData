#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import pg
import re
import csv
import types
import getopt
#import datetime
import kmlbase
import kmldom
import kmlengine
import kmlcedric
import mypass

class GeoCensus():
    """Generates KML based on Census Geo and Data"""

    pgconn = None
    GCHARTURL = "http://chart.apis.google.com/chart"
    GEO_AVAIL = ["coast", "dc", "dc_land", "dcca", "tpu_small", "tpu_large", "tpu", "tsb_small", "dist_nt"]
    GEO_KEYS = {"dc_land2": "dc"}
    GEO_W_NUMKEYS = ["tpu2006"]

    def __init__(self, geo=None):
	self.pgconn = mypass.getConn()
	if geo is None:
	    self.key = None
	    self.geotable = None
	else:
	    self.geotable = geo
    	    if geo in self.GEO_KEYS:
    		self.key = self.GEO_KEYS[geo]
		self.geokey = self.GEO_KEYS[geo]
    	    else:
    		self.key = geo
		self.geokey = geo
	self.datatable = None
	self.geokml = dict()
	self.data = dict()
	self.factory = kmldom.KmlFactory_GetFactory()
	self.kml = self.factory.CreateElementById(kmldom.Type_kml)
	self.geo = None
	self.geokey = None
	self.geo_tolerance = None
	self.geo_mapping = dict() # for TPU to TPU_(LARGE|SMALL)
	self.output = None
	self.verbose = False
	self.outputformat = "csv"
	self.year = None

    def usage(self):
	print "geocensus.py [-c(csv)|-d(data)|-h(help)|-k(kml)|-o(output_file)|-v(verbose)]"

    def setGeo(self, geo):
	if self.geotable is None:
	    self.geotable = geo
	    if self.year is not None:
		self.geotable += str(self.year)
	if self.geokey is None:
	    if geo in self.GEO_KEYS:
		self.geokey = self.GEO_KEYS[geo]
	    else:
		self.geokey = geo

    def setYear(self, year):
	if self.geotable is not None:
	    self.geotable += str(year)
	self.year = int(year)

    def setGeoTolerance(self, tolerance):
	self.geo_tolerance = str(tolerance)

    def geodb(self):
	if self.geotable is None: # if geo is not specified, try to get it from datatable
	    if self.datatable is not None and len(self.data) > 0:
		geokey = self.pgconn.pkey("hkcensus.%s" % self.datatable)
		if type(geokey).__name__ == "frozenset":
		    for x in geokey:
			self.geokey = x
			if geokey in self.GEO_AVAIL:
			    self.setGeo(self.geokey)
			break
		elif geokey in self.GEO_AVAIL:
		    self.setGeo(geokey)
		else:
		    return 0
	    else:
		return 0
	    self.geotable = self.geokey
	if self.geo_tolerance is not None:
	    the_geom = "ST_SimplifyPreserveTopology(the_geom,%(tolerance)s)" % { "tolerance": self.geo_tolerance }
	else:
	    the_geom = "the_geom"
	sql_args = { "table_name": "hkcensus." + self.geotable, "orderby": self.geokey, "key": self.geokey, "the_geom": the_geom }
	sql = "SELECT %(key)s, ST_AsKML(%(the_geom)s) boundary, ST_AsKML(ST_Centroid(the_geom)) point FROM %(table_name)s ORDER BY %(orderby)s "
	if self.verbose:
	    print sql % sql_args
	resgeo = self.pgconn.query(sql % sql_args).dictresult()
	if self.verbose:
	    print str(len(resgeo)) + " results"
	    print "key: %s " % str(self.geokey)
	for x in resgeo:
	    self.geokml[str(x[self.geokey])] = x
	if self.geo_mapping is not None and len(self.geo_mapping) > 0:
	    for g in self.geo_mapping:
		mapping_str = list()
		for num in self.geo_mapping[g]:
		    if self.geotable in self.GEO_W_NUMKEYS:
			mapping_str.append(str(num))
		    else:
			mapping_str.append("'%s'" % str(num))
		nums = ",".join(mapping_str)
		sql = "SELECT '%(keyval)s' %(key)s, ST_AsKML(%(the_geom)s) boundary, ST_AsKML(ST_Centroid(%(the_geom)s)) point FROM %(table_name)s WHERE %(key)s IN (%(nums)s) "
		if self.geo_tolerance is not None:
		    the_geom = "ST_SimplifyPreserveTopology(ST_UNION(the_geom),%(tolerance)s)" % { "tolerance": self.geo_tolerance }
		else:
		    the_geom = "ST_UNION(the_geom)"
		sql_args = { "table_name": "hkcensus." + self.geotable, "orderby": self.geokey, "key": self.geokey, "the_geom": the_geom, "nums": nums, "keyval": g }
		if self.verbose:
		    print sql % sql_args
		resgeo = self.pgconn.query(sql % sql_args).dictresult()
		for x in resgeo:
		    self.geokml[str(x[self.geokey])] = x

    def getCensusData(self, datatable_name, keys=list()):
	self.datatable = datatable_name
    	datakey = self.pgconn.pkey("hkcensus.%s" % self.datatable)
	if self.key is None:
	    if type(datakey).__name__ == "frozenset":
		self.key = ",".join(datakey)
		if self.geokey is None:
		    for x in datakey:
		        self.geokey = x
		        break
	    elif type(datakey) is types.StringType:
		self.key = datakey
		if self.geokey is None:
		    self.geokey = datakey
	sql_args = { "table_name": "hkcensus." + datatable_name, "in": "", "orderby": self.key, "key": self.key }
	keys_str = list()
	for k in keys:
	    keys_str.append(str(k))
	#if len(keys) > 0 and len(primary_key) > 0:
	#    sql_args["in"] = " WHERE %(key)s IN (%(ids)s) " % { "key": self.key, "ids": ",".join(keys_str) }
	sql = "SELECT * FROM %(table_name)s %(in)s ORDER BY %(orderby)s "
	print sql % sql_args
	resdata = self.pgconn.query(sql % sql_args).dictresult()
	for x in resdata:
	    if "," in self.key:
		thiskey_arr = list()
		for k in self.key.split(","):
		    thiskey_arr.append(x[k])
		thiskey = ",".join(thiskey_arr)
	    else:
		thiskey = x[self.key]
	    self.data[thiskey] = x
	    if "," in thiskey or "&" in thiskey or "-" in thiskey:
		geoset1 = re.sub(r"[,&]+","", thiskey).split()
		geoset = list()
		for g in geoset1:
		    if "-" in g:
			m1 = re.match(r"(\d+)-(\d+)", g)
			if m is not None:
			    start = int(m.group(1))
			    end = int(m.group(2))
			    for num in range(start,end+1):
				geoset.append(str(num))
		    else:
			geoset.append(str(g))
		m2 = re.match(r"([\d/]+)", thiskey.strip())
		if m2 is not None:
		    self.geo_mapping[m2.group(1)] = geoset

    def genText(self, outformat="csv"):
	if self.verbose:
	    print "generating %s..." % outformat.upper()
	if "," in self.key:
	    cols = self.key.split(",")
	else:
	    cols = [self.key]
	if self.verbose:
	    print "rows of data: %d" % len(self.data)
	if len(self.data) > 0:
	    datacols = self.data[self.data.keys()[0]].keys()
	    datacols.sort()
	    if "," in self.key:
		for k in self.key.split(","):
		    datacols.remove(k)
	    else:
		datacols.remove(self.key)
	    cols.extend(datacols)
	if len(self.geokml):
	    cols.extend(["point", "boundary"])
	if self.output is None:
	    out = sys.stdout
	else:
	    out = open(self.output, "w")
	if self.verbose:
	    print cols
	if outformat == "csv":
	    cw = csv.DictWriter(out, cols)
	    cw.writeheader()
	else:
	    txt = list()
	if len(self.data) > 0:
	    datakeys = self.data.keys()
	    datakeys.sort()
	    for x in datakeys:
		if len(self.geokml):
		    row = dict() 
		    if "," in self.key: # composite pkey
			x_geo = self.getGeoNumber(x.split(",")[0]) # assume first is geokey
			for k in self.key.split(","):
			    row[k] = k
		    else:
			x_geo = self.getGeoNumber(x)
			row[self.key] = x
		    if x_geo is None:
			continue
		    row["point"] = self.geokml[x_geo]["point"]
		    row["boundary"] = self.geokml[x_geo]["boundary"]
		    row = dict(row.items() + self.data[x].items())
		else:
		    row = self.data[x]
		if outformat == "csv":
		    cw.writerow(row)
		else:
		    txt.append(row)
	elif self.geokml is not None:
	    geokmlkeys = self.geokml.keys()
	    geokmlkeys.sort()
	    for x in geokmlkeys:
		row = { self.geokey: x, "point": self.geokml[x]["point"], "boundary": self.geokml[x]["boundary"] }
		if outformat == "csv":
		    cw.writerow(row)
		else:
		    txt.append(row)
	if len(self.data) > 0 or self.geokml is not None:
	    if outformat == "json":
		out.write(json.dumps(txt))
	    elif outformat == "sql":
		if len(self.data) > 0:
		    tablename = self.datatable
		elif self.geokml is not None:
		    tablename = self.geotable
		for r in txt:
		    keys = r.keys()
		    #values = r.values()
		    values_str = list()
		    #for v in values:
		    has_nulls = False
		    for k in keys:
			v = r[k]
			if type(v) is types.StringType:
			    v = v.replace("'","''")
			    v = "'%s'" % v
			elif type(v) is types.NoneType:
			    del r[k]
			    v = ""
			    has_nulls = True
			    continue
			values_str.append(str(v))
		    args = { "tablename": tablename, "keys": ",".join(r.keys()), "vals": ",".join(values_str) }
	    	    out.write("INSERT INTO %(tablename)s (%(keys)s) VALUES (%(vals)s) ;\n" % args)
    
    def genKml(self):
	if self.verbose:
	    print "generating KML..."
	self.genKmlGeo()
	if self.output is None:
	    print kmldom.SerializePretty(self.kml)
	else:
	    f = open(self.output, "w")
	    f.write(kmldom.SerializePretty(self.kml))
	    f.close()

    def genKmlGeo(self):
	docu = self.factory.CreateDocument()
	self.kml = self.factory.CreateElementById(kmldom.Type_kml)
	kmlfile = kmlengine.KmlFile.CreateFromImport(self.kml)
	self.kml = kmldom.AsKml(kmlfile.get_root())
	self.kml.set_feature(docu)
	if len(self.data) > 0:
	    keys = self.data.keys()
	elif self.geokml is not None:
	    keys = self.geokml.keys()
    	keys.sort()
	for x in keys:
	    x_geo = self.getGeoNumber(x)
	    x_safe = x_geo.replace("/", "_")
	    geoprefix = self.geotable.replace("_","")
	    plid = geoprefix + "-" + x_safe
	    if x_geo is None:
		continue
	    pl = self.factory.CreatePlacemark()
	    pl.set_name(x)
	    pl.set_id(plid)
	    point_kml = self.geokml[x_geo]["point"]
	    point_text = ''
	    if type(point_kml) is types.ListType:
		try:
		    point_kml = "".join(point_kml)
		except TypeError:
		    point_kml = ""
	    if "boundary" in self.geokml[x_geo]:
		bounds_kml = self.geokml[x_geo]["boundary"]
		if type(bounds_kml) is types.ListType:
		    try:
			bounds_kml = "".join(bounds_kml)
		    except:
			continue
		if bounds_kml.startswith('<Polygon>'):
		    bounds_kml = '<MultiGeometry>' + bounds_kml + '</MultiGeometry>'
		try:
		    bounds_kml = bounds_kml.replace("</MultiGeometry><MultiGeometry>", "")
		    bounds_points_kml = bounds_kml.replace("<MultiGeometry>", "<MultiGeometry>" + point_kml)
		    kmlfile,errors = kmlengine.KmlFile.CreateFromParse(bounds_points_kml)
		except:
		    bounds_kml = self.geokml[x_geo]["boundary"][0]
		    bounds_points_kml = bounds_kml.replace("<MultiGeometry>", "<MultiGeometry>" + point_kml)
		    kmlfile,errors = kmlengine.KmlFile.CreateFromParse(bounds_points_kml)
		mg = kmldom.AsMultiGeometry(kmlfile.get_root())
	    else:
		kmlfile,errors = kmlengine.KmlFile.CreateFromParse("<MultiGeometry>"+point_kml+"</MultiGeometry>")
		mg = kmldom.AsMultiGeometry(kmlfile.get_root())
	    pl.set_geometry(mg)
	    pl.set_styleurl('#' + plid)
	    docu.add_feature(pl)

    def gen(self):
	if self.outputformat == "csv":
	    self.genText()
	elif self.outputformat == "json":
	    self.genText("json")
	elif self.outputformat == "sql":
	    self.genText("sql")
	else:
	    self.genKml()

    def getGeoNumber(self, x):
	x_geo = x.strip()
	if x_geo not in self.geokml:
	    m = re.match(r"([\d/]+)", x_geo)
	    if m is not None:
		x_geo = m.group(0) # x_geo is numeric
		if x_geo + "L" in self.geokml: # large
		    x_geo += "L"
		elif x_geo + "S" in self.geokml: # small
		    x_geo += "S"
		elif x_geo in self.geokml: # found
		    pass
		else: # cannot find suffixed geo number
		    return None
	    else:
		return None
	return x_geo

def main():
    gc = GeoCensus()
    censusdata = None
    try:
        opts, args = getopt.getopt(sys.argv[1:], "chjksvo:g:t:d:y:", ["help", "output=", "--geo", "--tolerance", "--data", "csv", "kml", "--key", "--sql", "--json", "--year"])
    except getopt.GetoptError, err:
        # print help information and exit:
        print str(err) # will print something like "option -a not recognized"
        gc.usage()
        sys.exit(2)
    if len(sys.argv) <= 1:
        gc.usage()
	sys.exit()
    for o, a in opts:
        if o == "-v":
            gc.verbose = True
        elif o in ("-h", "--help"):
            gc.usage()
            sys.exit()
        elif o in ("-o", "--output"):
            gc.output = a
	elif o in ("-g", "--geo"):
	    gc.setGeo(a)
	elif o in ("-t", "--tolerance"):
	    gc.setGeoTolerance(a)
	elif o in ("-d", "--data"):
	    #gc.getCensusData(a)
	    censusdata = a
	elif o in ("-c", "--csv"):
	    gc.outputformat = "csv"
	elif o in ("-s", "--sql"):
	    gc.outputformat = "sql"
	elif o in ("-j", "--json"):
	    gc.outputformat = "json"
	elif o in ("--kml"):
	    gc.outputformat = "kml"
	elif o in ("-k", "--key"):
	    gc.key = a
	elif o in ("-y", "--year"):
	    gc.setYear(a)
        else:
            assert False, "unhandled option"
    if gc.verbose:
	print gc.geotable
	print gc.outputformat
    if censusdata is not None:
	gc.getCensusData(censusdata)
    gc.geodb()
    gc.gen()
    # ...

if __name__ == "__main__":
    main()
