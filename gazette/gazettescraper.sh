#!/bin/bash

D=`date +%Y%m%d-%H%M`

toc_max=1

if [ $# -ge 1 ]
then
    toc_max=$1
fi

COOKIE=`curl -sI "http://www.gld.gov.hk/egazette/english/gazette/toc.php?Submit=accept" | grep -Eo "PHPSESSID=(\w+)" `

TOC="http://www.gld.gov.hk/egazette/english/gazette/toc.php"
VOL="http://www.gld.gov.hk/egazette/english/gazette/volume.php"

toc_i=0

while true
do
    # Get the TOC page
    IN="toc.${D}.${toc_i}.html"
    curl -sb "${COOKIE}" "http://www.gld.gov.hk/egazette/english/gazette/toc.php?page=${toc_i}" -o ${IN}
    # Retain the part we want
    #echo ${IN}
    LEN=`wc -l ${IN} | cut -d" " -f1`
    TOP=`grep -n "<table" ${IN} | cut -d: -f1`
    let TAIL=${LEN}-${TOP}
    let TAIL=${TAIL}+1
    tail -${TAIL} ${IN} > ${IN}.tail
    BOTTOM=`grep -n "</table>" ${IN}.tail | cut -d: -f1`
    let BOTTOM=${BOTTOM}+1
    let HEAD=${BOTTOM}
    echo "<div>" > ${IN}.out
    head -${HEAD} ${IN}.tail >> ${IN}.out
    # Change entities
    sed -i 's/&nbsp;/ /g' ${IN}.out
    # Send through the parser
    ./parse_toc.py ${IN}.out
    let toc_i=${toc_i}+1
    rm ${IN} ${IN}.tail ${IN}.out
    if [ ${toc_i} -gt ${toc_max} ]
    then
        break
    fi
done
