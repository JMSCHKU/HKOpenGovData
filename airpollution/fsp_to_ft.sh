#!/bin/bash
export PATH=${PATH}:${HOME}/bin

if [ $# -lt 1 ]
then
    echo "Missing date"
    exit
fi

TABLEID="1yJdri8_uLcrUQe0pENr0VUGhs9vXxTFYLdcPezA"

DATE=$1

SQL=`cat generate_records.sql | sed "s/\\$1/${DATE}/g"`

CSVFILE="fsp_${DATE}.csv"
psql -h 127.0.0.1 -U opengov -c "${SQL}" -tA -F, -o ${CSVFILE}

ftimport.py ${TABLEID} ${CSVFILE}

TARGZFILE="fsp_${DATE}.tar.gz"
tar cvzf ${TARGZFILE} ${CSVFILE} > /dev/null
mv ${TARGZFILE} archive_per_date
rm ${CSVFILE}
