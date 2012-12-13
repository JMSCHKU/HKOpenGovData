#!/bin/bash

DIR=`pwd`

DO=`date +%Y%m%d-%H%M`
DYESTERDAY=`date -d"1 day ago" +%Y-%m-%d`

curl -s "http://www.weather.gov.hk/wxinfo/pastwx/ryes.htm" -o daily/${DYESTERDAY}.html
