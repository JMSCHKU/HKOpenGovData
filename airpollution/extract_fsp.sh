#!/bin/bash

if [ $# -lt 1 ]
then
    echo "Missing file"
    exit
fi

grep -E "201[2-9]-" -A7 $1 | sed -e :a -e 's/<[^>]*>//g;/</N;//ba;s/^[ \t\n\r]*//g;s/[ \t\n\r]*$//g' > $1.out

F=`echo "$1" | grep -oE '[^\/]*$'`
PLACE=`echo ${F} | grep -Eo "^[a-Z_]*" | sed 's/_$//'`
DATE=`echo ${F} | grep -Eo "[0-9_\-]*.html" | sed 's/^_//' | sed 's/\.html//g' `
COUNT=0
LINE=""
while read i
do
    let POS=${COUNT}%9
    let COUNT=${COUNT}+1
    if [ "${i}" == "--" ]
    then
        i=""
    fi
    if [ ${POS} -eq 6 ]
    then
        continue
    elif [ ${POS} -eq 8 ]
    then
        echo ${LINE}
    else
        if [ ${POS} -eq 0 ]
        then
            LINE=${PLACE},${DATE}
        fi
        LINE="${LINE},${i}"
    fi
done < $1.out

rm $1.out
