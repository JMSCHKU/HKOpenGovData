#!/bin/bash

D=`pwd`
DIR=${PWD}/fsp

cd ${DIR}

DO=`date +%Y%m%d-%H%M`
DH=`date +%H`
HOURSTOSAVE=0
if [ `echo "$1" | wc -m` -ge 2 ]
then
    HOURSTOSAVE=$1
fi
CSV="batch_${DO}.csv"

touch ${CSV}

while read dist
do
    #echo $C
    curl -s "http://www.epd-asg.gov.hk/tc_chi/24pollu_fsp/${dist}_fsp.html" -o chi/${dist}_chi_${DO}.html
    curl -s "http://www.epd-asg.gov.hk/english/24pollu_fsp/${dist}_fsp.html" -o ${dist}_${DO}.html
    ${D}/extract_fsp.sh ${dist}_${DO}.html >> ${CSV}
    if [ ${DH} -ne 12 ] || [ ${DH} -ne 0 ] # delete to save space
    then
        rm chi/${dist}_chi_${DO}.html
        rm ${dist}_${DO}.html
    fi
done < ${D}/districts.txt

if [ ${HOURSTOSAVE} -gt 0 ]
then
    NEWCSV="batch_${DO}_${HOURSTOSAVE}_hours.csv"
    let HOURSTOSAVE=${HOURSTOSAVE}-1
    for hour in `seq 0 ${HOURSTOSAVE}`
    do
        hoursago=`date -d"${hour} hours ago" +%Y-%m-%d\ %H`:00
        grep "${hoursago}" ${CSV} >> ${NEWCSV}
    done
    psql -h 127.0.0.1 -U opengov -c "\\copy epd.airpollution from '${NEWCSV}' csv "
    cd ${D}
    ${D}/fsp_to_ft.sh ${hoursago}
    cd - > /dev/null
else
    psql -h 127.0.0.1 -U opengov -c "\\copy epd.airpollution from '${CSV}' csv "
fi

rm ${CSV}
