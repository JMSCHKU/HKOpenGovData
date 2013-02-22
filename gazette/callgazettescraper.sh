#!/bin/bash

MAXTRIES=20
TRIES=0

#curl -s "http://www.gld.gov.hk/egazette/english/gazette/disclaimer.php" -o /dev/null
#curl -s "http://www.gld.gov.hk/egazette/english/gazette/toc.php?Submit=accept" -o /dev/null

while true
do
    let TRIES=${TRIES}+1
    OUT=`./gazettescraper.sh`
    LASTROW=`echo "${OUT}" | tail -1`
    if [ "${LASTROW}" == "SUCCESS" ]
    then
        break
    else
        echo "${OUT}"
    fi
    echo "Tried ${TRIES} times"
    sleep 15
    if [ ${TRIES} -ge ${MAXTRIES} ]
    then
        echo "Unsuccessful"
        break
    fi
done
