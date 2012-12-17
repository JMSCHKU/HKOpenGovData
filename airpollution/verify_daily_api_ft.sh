#!/bin/bash

if [ $# -lt 1 ]
then
    echo "Missing date"
    exit
fi

DATE=$1
TABLEID="1BstJdxsEVa_RvJw3OMNpep-HbsmE72kygrBPVFg"
DATESHORT=`echo "$1" | sed 's/-//g'`

SQL="SELECT Date FROM ${TABLEID} WHERE Date = '${DATE}' "

ftsql.py GET "${SQL}" > verify_daily_api_${DATESHORT}.json

grep ${DATE} verify_daily_api_${DATESHORT}.json | sed 's/^ *//g' | sed 's/[",]*//g' > verify_daily_api_dates_${DATESHORT}.txt

FOUND=`grep "^${DATE}$" verify_daily_api_dates_${DATESHORT}.txt | wc -l`
if [ ${FOUND} -eq 0 ]
then
    ./daily_api_to_ft.sh ${DATE}
fi

rm verify_daily_api_${DATESHORT}.json
rm verify_daily_api_dates_${DATESHORT}.txt
