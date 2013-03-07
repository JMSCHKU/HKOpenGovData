#!/bin/bash

DIR=/var/data/marine/arrivals_departures

cd ${DIR}

pages=( enter arrive inport depart )

D=`date +%Y%m%d-%H%M`

for P in ${pages[@]}
do
    #echo $P
    curl -s "http://www.mardep.gov.hk/en/pub_services/vl${P}.html" -o vl${P}_${D}.xml
    curl -s "http://www.mardep.gov.hk/en/pub_services/vlrt${P}.html" -o vlrt${P}_${D}.xml
done
