#!/bin/bash

DDAY=`date +%Y%m%d`
D=`date +%Y%m%d-%H`
DHOUR="`date +%Y-%m-%d\ %H:`:00"

curl -s "http://www.epd-asg.gov.hk/eindex.html" -o current_api/currentapi_${D}.html

html2text -style pretty -width 1000 current_api/currentapi_${D}.html > current_api/currentapi_${D}.txt

./extract_current_api.sh current_api/currentapi_${D}.txt "${DHOUR}" > current_api/currentapi_${D}.csv

head -1 current_api/currentapi_${D}.csv > current_api/currentapi_${DDAY}.csv

tail -q -n1 current_api/currentapi_${DDAY}-*.csv >> current_api/currentapi_${DDAY}.csv

rm current_api/currentapi_latest.csv
rm current_api/currentapi_latest_day.csv

ln -s currentapi_${D}.csv current_api/currentapi_latest.csv
ln -s currentapi_${DDAY}.csv current_api/currentapi_latest_day.csv

rm current_api/currentapi_${D}.html
