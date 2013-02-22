#!/bin/bash

if [ $# -lt 1 ]
then
    echo "Missing file"
    exit
fi

while read i
do
    COOKIE=`curl -s -I "http://www.gld.gov.hk/egazette/english/gazette/toc.php?Submit=accept" | grep -Eo "PHPSESSID=(\w+)" `
    vol=`echo $i | grep -oE "&vol=([0-9]+)" | grep -oE "[0-9]+" `
    no=`echo $i | grep -oE "&no=([0-9]+)" | grep -oE "[0-9]+" `
    extra=`echo $i | grep -oE "extra=([0-9]+)" | grep -oE "[0-9]+" `
    Y=`echo $i | grep -oE "&year=([0-9]{4})" | grep -oE "[0-9]{4}" `
    m=`echo $i | grep -oE "&month=([0-9]{2})" | grep -oE "[0-9]{2}" `
    d=`echo $i | grep -oE "&day=([0-9]{2})" | grep -oE "[0-9]{2}" `
    gn=`echo $i | grep -oE "&gn=([0-9]{1,})" | grep -oE "[0-9]{1,}" `
    typ=`echo $i | grep -oE "&type=([0-9]{1,})" | grep -oE "[0-9]{1,}" `
    id=`echo $i | grep -oE "&id=([0-9]{1,})" | grep -oE "[0-9]{1,}" `
    FO="${Y}-${m}-${d}_${vol}-${no}_${extra}_${typ}_${id}"
    URL=`echo "http://www.gld.gov.hk/egazette/english/gazette/${i}"`
    #echo $COOKIE
    #echo $URL
    LOC=`curl -s -I -b "${COOKIE}" "${URL}" | grep -Eo "Location: (.*)" | cut -d: -f2 | sed 's/[ ]\{1,\}..\/..\/..\/egazette\///g' | sed 's/[ \t\r\n]\+$//g'`
    URLPDF=`echo "http://www.gld.gov.hk/egazette/$LOC"`
    wget "${URLPDF}"
    echo ${URL} ${URLPDF}
    if [ `ls ${URLPDF} 2> /dev/null | wc -l` -ge 1 ]
    then
        echo ${URLPDF}
    else
        rm ${URLPDF} 2> /dev/null
    fi
done < $1
