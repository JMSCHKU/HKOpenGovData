#!/bin/bash

if [ $# -lt 1 ]
then
    echo "Missing file"
    exit
fi

while read i
do
    if [ `echo $i | grep -oE "^volume.php" | wc -m` -le 0 ]
    then
        continue
    fi
    COOKIE=`curl -sI "http://www.gld.gov.hk/egazette/english/gazette/toc.php?Submit=accept" | grep -Eo "PHPSESSID=(\w+)" `
    sleep 0.2
    i=`echo $i | sed 's/&amp;/\&/g'`
    vol=`echo $i | grep -oE "&vol=([0-9]+)" | grep -oE "[0-9]+" `
    no=`echo $i | grep -oE "&no=([0-9]+)" | grep -oE "[0-9]+" `
    extra=`echo $i | grep -oE "extra=([0-9]+)" | grep -oE "[0-9]+" `
    Y=`echo $i | grep -oE "&year=([0-9]{4})" | grep -oE "[0-9]{4}" `
    m=`echo $i | grep -oE "&month=([0-9]{2})" | grep -oE "[0-9]{2}" `
    d=`echo $i | grep -oE "&day=([0-9]{2})" | grep -oE "[0-9]{2}" `
    FO="${Y}-${m}-${d}_${vol}-${no}_${extra}.html"
    URL=`echo "http://www.gld.gov.hk/egazette/english/gazette/${i}" | sed 's/&amp;/\&/g'`
    curl -s -b "${COOKIE}" "${URL}" -o "${FO}"
    if [ `ls ${FO} 2> /dev/null | wc -l` -ge 1 ]
    then
        echo $FO
    else
        rm ${FO} 2> /dev/null
    fi
done < $1
