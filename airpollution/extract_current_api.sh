#!/bin/bash

if [ $# -lt 1 ]
then
    echo "Missing file"
    exit
fi
if [ $# -lt 2 ]
then
    recorded="`date +%Y-%m-%d\ %H`:00"
else
    recorded=$2
fi
date=`echo $recorded | cut -d" " -f1`
hour=`echo $recorded | cut -d" " -f2 | cut -d":" -f1`

STNS="recorded,date,hour"
APIS="${recorded},${date},${hour}"
while read i
do
    LINE=`grep -Eo " ${i} +[0-9\-]+" $1`
    L=`echo $LINE | sed 's/ /,/g' | sed 's/-//g' | sed 's/_/ /g'`
    STN=`echo $L | cut -d, -f1`
    API=`echo $L | cut -d, -f2`
    STNS="${STNS},${STN}"
    APIS="${APIS},${API}"
done < districts_current_api.txt

echo ${STNS}
echo ${APIS}
