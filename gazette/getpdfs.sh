#!/bin/bash

cd pdfs

if [ $# -lt 1 ]
then
    echo "Missing file"
    exit
fi

secondpass=0
if [ $# -gt 1 ]
then
    case $2 in
    2)
        secondpass=1 ;;
    esac
fi

while read i
do
    if [ ${secondpass} -eq 1 ]
    then
        ref=`echo ${i} | cut -d\| -f2`
        i=`echo ${i} | cut -d\| -f1`
    fi
    COOKIE=`curl -sI "http://www.gld.gov.hk/egazette/english/gazette/toc.php?Submit=accept" | grep -Eo "PHPSESSID=(\w+)" `
    PAGE=`echo "${i}" -d\| -f1`
    URL=`echo "http://www.gld.gov.hk/egazette/english/gazette/${PAGE}"`
    LOC=`curl -s -I -b "${COOKIE}" "${URL}" | grep -Eo "Location: (.*)" | cut -d: -f2 | sed 's/[ ]\{1,\}..\/..\/..\/egazette\///g' | sed 's/[ \t\r\n]\+$//g'`
    URLPDF=`echo "http://www.gld.gov.hk/egazette/$LOC"`
    FO=`echo $LOC | sed 's/^pdf\///' | sed 's/\//_/g'`
    if [ ! -f ${FO} ]
    then
        curl -s -b "${COOKIE}" "${URLPDF}" -o ${FO}
    fi
    if [ `ls ${FO} 2> /dev/null | wc -l` -ge 1 ]
    then
        i=`echo ${i} | sed 's/[\r\n]\+//g'`
        if [ ${secondpass} -eq 1 ]
        then
            i="$ref|$i"
        fi
        echo ${i},${FO},`md5sum ${FO} | cut -d" " -f1`
    else
        echo "${i},,"
    fi
done < ../$1

cd ..
