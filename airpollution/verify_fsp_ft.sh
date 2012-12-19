#!/bin/bash
export PATH=${PATH}:${HOME}/bin

if [ $# -lt 1 ]
then
    echo "Missing date"
    exit
fi

DATE=$1
DATEHOUR="$1 $2"
TABLEID="1yJdri8_uLcrUQe0pENr0VUGhs9vXxTFYLdcPezA"
DATESHORT=`echo "$1" | sed 's/-//g'`

SQL="SELECT recorded, count() FROM ${TABLEID} WHERE date = '${DATE}' GROUP BY recorded "
if [ "${DATE}" != "`echo ${DATEHOUR} | sed 's/ *$//g'`" ]
then 
    SQL="SELECT recorded, count() FROM ${TABLEID} WHERE recorded = '${DATEHOUR}' GROUP BY recorded "
fi

ftsql.py GET "${SQL}" > verify_fsp_${DATESHORT}.json

if [ "${DATE}" != "`echo ${DATEHOUR} | sed 's/ *$//g'`" ]
then
    grep ${DATE} verify_fsp_${DATESHORT}.json | sed 's/^ *//g' | sed 's/[",]*//g' > verify_fsp_dates_${DATESHORT}.txt
    FOUND=`grep "^${DATEHOUR}$" verify_fsp_dates_${DATESHORT}.txt | wc -l`
    if [ ${FOUND} -eq 0 ]
    then
        echo "NOT FOUND: ${DATEHOUR}"
        echo "trying insert again..."
        ./fsp_to_ft.sh ${DATEHOUR} -e
    fi
else
    grep ${DATE} verify_fsp_${DATESHORT}.json | sed 's/^ *//g' | sed 's/[",]*//g' | sed "s/${DATE} //g" | sed 's/:00:00//g' > verify_fsp_dates_${DATESHORT}.txt
    for i in `seq -f "%02g" 23`
    do
        FOUND=`grep "^${i}$" verify_fsp_dates_${DATESHORT}.txt | wc -l`
        if [ ${FOUND} -eq 0 ]
        then
            echo "NOT FOUND: ${DATE} (${i})"
            echo "trying insert again..."
            ./fsp_to_ft.sh ${DATE} ${i}:00:00 -e
        fi
    done
fi

rm verify_fsp_${DATESHORT}.json
rm verify_fsp_dates_${DATESHORT}.txt
