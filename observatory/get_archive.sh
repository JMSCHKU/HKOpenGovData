#!/bin/bash

while read stn
do
    for y in `seq 1997 2012`
    do
        for m in `seq -f '%02g' 01 12`
        do
            echo $stn $y$m
            curl "http://www.hko.gov.hk/cis/data/awsext/${y}/ext_${stn}${y}${m}_e.htm" -o archive/ext_${stn}${y}${m}_e.html
        done
    done
done < stations.txt
