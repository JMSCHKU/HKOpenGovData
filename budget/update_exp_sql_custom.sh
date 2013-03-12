#!/bin/bash

if [ $# -lt 1 ]
then
    echo "missing file"
    exit
fi

while read line
do
    year=`echo $line | cut -d, -f1`
    head=`echo $line | cut -d, -f2`
    actual=`echo $line | cut -d, -f3`
    approved=`echo $line | cut -d, -f4`
    revised=`echo $line | cut -d, -f5`
    estimate=`echo $line | cut -d, -f6`
    if [ "${actual}" == "" ]; then actual="null"; fi
    if [ "${approved}" == "" ]; then approved="null"; fi
    if [ "${revised}" == "" ]; then revised="null"; fi
    if [ "${estimate}" == "" ]; then estimate="null"; fi
    updatesql="UPDATE budget.expenditures SET actual${year} = ${actual}, approved${year} = ${approved}, revised${year} = ${revised}, estimate${year} = ${estimate} WHERE head = ${head} "
    echo "${updatesql}"
    #psql -h 127.0.0.1 -U opengov -c "${updatesql}"
done < $1
