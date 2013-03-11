#!/bin/bash
export PATH=${PATH}:${HOME}/bin

DIR=`pwd`

DYESTERDAY=`date -d"1 day ago" +%Y-%m-%d`

TABLEID="1R4Pwp33NN4denK2E0CpUP9614f4HfU0lha55_D4"

curl -s "http://www.weather.gov.hk/textonly/pastwx/ryestxt.htm" -o daily/${DYESTERDAY}.html

./isolate_daily.sh daily/${DYESTERDAY}.html > daily/${DYESTERDAY}.txt

./parse_daily.sh daily/${DYESTERDAY}.txt > daily/${DYESTERDAY}.csv

ftimport.py ${TABLEID} daily/${DYESTERDAY}.csv

cat daily/${DYESTERDAY}.csv >> daily_weather_hk.csv

rm daily/${DYESTERDAY}.csv

