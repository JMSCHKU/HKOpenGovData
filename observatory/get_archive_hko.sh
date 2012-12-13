#!/bin/bash

for y in `seq 1997 2012`
do
    for m in `seq -f '%02g' 01 12`
    do
        echo $stn $y$m
        curl "http://www.hko.gov.hk/wxinfo/pastwx/metob${y}${m}.htm" -o archive/metob${y}${m}.html
    done
done

