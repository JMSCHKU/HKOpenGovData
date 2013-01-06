#!/bin/bash

for i in `seq 2006 2014`
do
    echo $i
    while read line
    do
        head=`echo $line | cut -d, -f1`
        actual=`echo $line | cut -d, -f2`
        approved=`echo $line | cut -d, -f3`
        revised=`echo $line | cut -d, -f4`
        estimate=`echo $line | cut -d, -f5`
        if [ ${actual} == "" ]; then actual="null"; fi
        if [ ${approved} == "" ]; then approved="null"; fi
        if [ ${revised} == "" ]; then revised="null"; fi
        if [ ${estimate} == "" ]; then estimate="null"; fi
        updatesql="UPDATE budget.expenditures SET actual${i} = ${actual}, approved${i} = ${approved}, revised${i} = ${revised}, estimate${i} = ${estimate} WHERE head = ${head} "
        psql -h 127.0.0.1 -U opengov -c "${updatesql}"
    done < sum_exp_e_${i}.csv
done
