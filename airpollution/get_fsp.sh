#!/bin/bash

D=`pwd`
DIR=${PWD}/fsp

cd ${DIR}

DO=`date +%Y%m%d-%H%M`
CSV="batch_${DO}.csv"

touch ${CSV}

while read dist
do
    #echo $C
    curl -s "http://www.epd-asg.gov.hk/tc_chi/24pollu_fsp/${dist}_fsp.html" -o chi/${dist}_chi_${DO}.html
    curl -s "http://www.epd-asg.gov.hk/english/24pollu_fsp/${dist}_fsp.html" -o ${dist}_${DO}.html
    ${D}/extract_fsp.sh ${dist}_${DO}.html >> ${CSV}
done < ${D}/districts.txt

psql -h 127.0.0.1 -U opengov -c "\\copy epd.airpollution from '${CSV}' csv "

rm ${CSV}
