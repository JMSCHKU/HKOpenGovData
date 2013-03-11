#!/bin/bash
export PATH=${PATH}:${HOME}/bin

DATE=`date -d"1 day ago" +%Y-%m-%d`
TABLEID="1R4Pwp33NN4denK2E0CpUP9614f4HfU0lha55_D4"
DATESHORT=`echo "${DATE}" | sed 's/-//g'`

SQL="SELECT date FROM ${TABLEID} WHERE date = '${DATE}' "

ftsql.py GET "${SQL}" > verify_daily_weather_${DATESHORT}.json

grep ${DATE} verify_daily_weather_${DATESHORT}.json | sed 's/^ *//g' | sed 's/[",]*//g' > verify_daily_weather_dates_${DATESHORT}.txt

FOUND=`grep "^${DATE}$" verify_daily_weather_dates_${DATESHORT}.txt | wc -l`
if [ ${FOUND} -eq 0 ]
then
    ./get_hko.sh ${DATE}
fi

rm verify_daily_weather_${DATESHORT}.json
rm verify_daily_weather_dates_${DATESHORT}.txt
