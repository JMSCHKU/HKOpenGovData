#!/bin/bash

D=`date +%Y%m%d-%H%M%S`

toc_max=1

if [ $# -ge 1 ]
then
    toc_max=$1
fi


BASEURL="http://www.gld.gov.hk/egazette/english/gazette/"
TOC="http://www.gld.gov.hk/egazette/english/gazette/toc.php"
VOL="http://www.gld.gov.hk/egazette/english/gazette/volume.php"

toc_i=0

echo "Processing table of contents..."

VOLS="vols.${D}.csv"
echo "date,volume,number,type,rev,link" > ${VOLS}
while true
do
    COOKIE=`curl -sI "http://www.gld.gov.hk/egazette/english/gazette/toc.php?Submit=accept" | grep -Eo "PHPSESSID=(\w+)" `
    # Get the TOC page
    IN="toc.${D}.${toc_i}.html"
    curl -sb "${COOKIE}" "${TOC}?page=${toc_i}" -o ${IN}
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
    ./parse_toc.py ${IN}.out >> ${VOLS}
    let toc_i=${toc_i}+1
    rm ${IN} ${IN}.tail ${IN}.out
    if [ ${toc_i} -gt ${toc_max} ]
    then
        break
    fi
done

sleep 1

VOLS_URLS="vols.urls.${D}.csv"
GAZETTES="gazettes.${D}.csv"
GAZETTES_URLS="gazettes.urls.${D}.csv"
cut -d, -f6 ${VOLS} > ${VOLS_URLS}
if [ ! -r ${VOLS_URLS} ] || [ `wc -l ${VOLS_URLS} | cut -d" " -f1` -le 0 ]
then
    echo "Volumes file ${VOLS_URLS} not found. Exiting..."
    rm ${VOLS}
    exit
fi
./getvol.sh ${VOLS_URLS} >> ${GAZETTES}

echo "Processing volume pages..."

while read IN
do
    echo ${IN}
    if [ ! -r ${IN} ]
    then
        continue
    fi
    LEN=`wc -l ${IN} | cut -d" " -f1`
    TOP=`grep -n '<p class="h2">' ${IN} | cut -d: -f1`
    let TAIL=${LEN}-${TOP}
    let TAIL=${TAIL}+1
    tail -${TAIL} ${IN} > ${IN}.tail
    BOTTOM=`grep -n '<script type="text/javascript">var last_revision_date' ${IN}.tail | cut -d: -f1`
    let BOTTOM=${BOTTOM}+1
    let HEAD=${BOTTOM}
    echo "<div>" > ${IN}.out
    head -${HEAD} ${IN}.tail >> ${IN}.out
    sed -i 's/&/\&amp;/g' ${IN}.out
    sed -i 's/<img [^>]\+>//g' ${IN}.out
    # Send through the parser
    ./parse_gaz.py ${IN}.out >> ${GAZETTES_URLS}
    rm ${IN} ${IN}.tail ${IN}.out
done < ${GAZETTES}

PDFLISTS="pdflists.${D}.csv"
PDFLISTS_URLS="pdflists.urls.${D}.csv"
if [ ! -r ${GAZETTES_URLS} ] || [ `wc -l ${GAZETTES_URLS} | cut -d" " -f1` -le 0 ]
then
    echo "Gazette file ${GAZETTES_URLS} not found. Exiting..."
    rm ${VOLS} ${VOLS_URLS} ${GAZETTES}
    exit
fi
./getlinks.sh ${GAZETTES_URLS} >> ${PDFLISTS}

echo "Processing PDF listing pages..."

while read IN
do
    echo ${IN}
    if [ ! -r ${IN} ]
    then
        continue
    fi
    LEN=`wc -l ${IN} | cut -d" " -f1`
    TOP=`grep -n '<p class="h2">' ${IN} | cut -d: -f1`
    let TAIL=${LEN}-${TOP}
    let TAIL=${TAIL}+1
    tail -${TAIL} ${IN} > ${IN}.tail
    if [ `grep '<script type="text/javascript">var last_revision_date' ${IN}.tail | wc -l` -ge 1 ]
    then
        BOTTOM=`grep -n '<script type="text/javascript">var last_revision_date' ${IN}.tail | cut -d: -f1`
    else
        BOTTOM=`grep -n '</table>' ${IN}.tail | cut -d: -f1`
    fi
    let BOTTOM=${BOTTOM}
    let HEAD=${BOTTOM}
    echo "<root>" > ${IN}.out
    head -${HEAD} ${IN}.tail >> ${IN}.out
    dos2unix -q ${IN}.out
    sed -i 's/&nbsp;/ /g' ${IN}.out
    sed -i 's/<br>/ \n/g' ${IN}.out
    sed -i 's/&/\&amp;/g' ${IN}.out
    sed -i 's/<img [^>]\+>//g' ${IN}.out
    if [ `echo ${IN}.out | grep "^ls6-" | wc -l` -ge 1 ]
    then
        sed -i 's/Insurance Companies Ordinance/Insurance Companies Ordinance<\/td>/g' ${IN}.out
    fi
    echo "</root>" >> ${IN}.out
    # Send through the parser
    ./parse_pdflist.py ${IN}.out >> ${PDFLISTS_URLS}
    rm ${IN} ${IN}.tail ${IN}.out
    #rm ${IN} ${IN}.tail
done < ${PDFLISTS}

if [ ! -r ${PDFLISTS_URLS} ] || [ `wc -l ${PDFLISTS_URLS} | cut -d" " -f1` -le 0 ]
then
    echo "PDF lists file ${PDFLISTS_URLS} not found. Exiting..."
    rm ${VOLS} ${VOLS_URLS} ${GAZETTES} ${PDFLISTS} ${GAZETTES_URLS} #${PDFLISTS_URLS}
    exit
fi

rm ${VOLS} ${VOLS_URLS} ${GAZETTES} ${PDFLISTS} ${GAZETTES_URLS} #${PDFLISTS_URLS}

echo SUCCESS
