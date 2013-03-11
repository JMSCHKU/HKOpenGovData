#!/bin/bash

export PATH=${PATH}:${HOME}/bin
TABLEID="1_78ewvJaEhr_18RLNVwybSs0ftt8QADSgdvgMoI"

if [ $# -lt 1 ]
then
    D=`date -d'1 month ago' +%Y%m`
else
    D=$1
fi

curl "http://www.hko.gov.hk/wxinfo/pastwx/metob${D}.htm" -o archive/metob${D}.html

html2text archive/metob${D}.html > archive/metob${D}.txt

./parse_archive.sh archive/metob${D}.txt > archive/metob${D}.csv

cat archive/metob${D}.csv >> metob_daily.csv

ftimport.py ${TABLEID} archive/metob${D}.csv
