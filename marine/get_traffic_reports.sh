#!/bin/bash

DIR=/var/data/marine/reports

cd ${DIR}

pages=( 04005 04505 05005 05505 06005 06505 07005 11501 )

D=`date +%Y%m%d`

for P in ${pages[@]}
do
    #echo $P
    curl -s "http://www.mardep.gov.hk/en/pub_services/RP${P}.XML" -o rp${P}_${D}.xml
done
