#!/bin/bash
export PATH=${PATH}:${HOME}/bin

DIR=`pwd`
cd api_daily

if [ $# -lt 1 ]
then
    echo "Missing date"
    exit
fi

TABLEID="1BstJdxsEVa_RvJw3OMNpep-HbsmE72kygrBPVFg"

DATE="$1"
DATEDAY=`echo "$1" | sed 's/-//g'`

YYYY=`date -d"${DATE}" +%Y`

curl -s "http://www.epd-asg.gov.hk/download/daily/eng/api${YYYY}.csv" -o ${YYYY}.csv

CSVFILE="daily_${DATEDAY}.csv"
grep -E "^${DATE}" ${YYYY}.csv | tail -1 > ${CSVFILE}
ftimport.py ${TABLEID} ${CSVFILE}

cat ${CSVFILE} >> aggr.csv

#ZIPFILE="daily_${DATEDAY}.zip"
#zip archive_daily/${ZIPFILE} ${CSVFILE} > /dev/null
rm ${CSVFILE}
