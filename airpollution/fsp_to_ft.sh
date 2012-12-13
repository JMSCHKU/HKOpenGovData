#!/bin/bash
export PATH=${PATH}:${HOME}/bin

if [ $# -lt 1 ]
then
    echo "Missing date"
    exit
fi

TABLEID="1yJdri8_uLcrUQe0pENr0VUGhs9vXxTFYLdcPezA"

DATE="$1 $2"
DATESHORT=`echo "${DATE}" | sed 's/[-:]//g' | sed 's/ /-/g' | sed 's/-$//g'`
DATEDAY=`echo "$1" | sed 's/ /-/g'`

if [ "$3" == "-e" ]
then
    SQL=`cat generate_records_equals.sql | sed "s/\\$1/${DATE}/g"`
elif [ `echo $2 | wc -m` -le 1 ]
then
    SQL=`cat generate_records_by_date.sql | sed "s/\\$1/${DATE}/g"`
else
    SQL=`cat generate_records_greater_than.sql | sed "s/\\$1/${DATE}/g"`
fi

CSVFILE="fsp_${DATESHORT}.csv"
psql -h 127.0.0.1 -U opengov -c "${SQL}" -tA -F, -o ${CSVFILE}

ftimport.py ${TABLEID} ${CSVFILE}

ZIPFILE="fsp_${DATEDAY}.zip"
zip archive_per_date/${ZIPFILE} ${CSVFILE} > /dev/null
rm ${CSVFILE}
