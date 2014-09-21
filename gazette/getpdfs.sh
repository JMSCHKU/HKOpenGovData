#!/bin/bash

cd pdfs

if [ $# -lt 1 ]
then
    echo "Missing file"
    exit
fi

let MAX_TRIES=20
tries=0
SLEEPSECS=5

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
    echo $i
    if [ ${secondpass} -eq 1 ]
    then
        ref=`echo ${i} | cut -d\| -f2`
        i=`echo ${i} | cut -d\| -f1`
    fi
    #COOKIE=`curl -sI "http://www.gld.gov.hk/egazette/english/gazette/toc.php?Submit=accept" | grep -Eo "PHPSESSID=(\w+)" `
    COOKIE=`curl -sI "http://www.gld.gov.hk/egazette/english/gazette/toc.php?Submit=accept" | grep -Eo "Set-Cookie: [^;]+" | cut -d" " -f2 | sed 's/$/;/' | sed ':a;N;$!ba;s/\n/ /g'`
    PAGE=`echo "${i}" | cut -d\| -f1`
    URL=`echo "http://www.gld.gov.hk/egazette/english/gazette/${PAGE}"`
    LOC=`curl -s -I -b "${COOKIE}" "${URL}" | grep -Eo "Location: (.*)" | cut -d: -f2 | sed 's/[ ]\{1,\}..\/..\/..\/egazette\///g' | sed 's/[ \t\r\n]\+$//g'`
    URLPDF=`echo "http://www.gld.gov.hk/egazette/$LOC"`
    FO=`echo $LOC | sed 's/^pdf\///' | sed 's/\//_/g'`
    if [ ! -s ${FO} ]
    then
        while true
        do
            curl -s -b "${COOKIE}" "${URLPDF}" -o ${FO}
            let tries=${tries}+1
            if [ -s "${FO}" ]
            then
                break
            else
                #echo "LOG: file empty: ${FO} (try #${tries})"
                if [ ${tries} -gt ${MAX_TRIES} ]
                then
                    #echo "LOG: Tried maximum times (${MAX_TRIES}) on ${FO}. Go to next file..."
                    break
                fi
                sleep 2
            fi
        done
        tries=0
        pdftotext -layout ${FO} > ../text/`echo ${FO} | sed 's/\.pdf/.txt/g'`
    fi
    if [ -s ${FO} ]
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
