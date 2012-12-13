#!/bin/bash

for y in `seq 2000 2012`
do
    for m in `seq -f '%02g' 01 12`
    do
        for d in `seq -f '%02g' 01 31`
        do
            echo $y$m$d
            curl "http://www.weather.gov.hk/cgi-bin/hko/yes.pl?year=${y}&month=${m}&day=${d}&language=english&B1=Confirm" -o daily/${y}-${m}-${d}.html
        done
    done
done

