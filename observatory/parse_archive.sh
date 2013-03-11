#!/bin/bash

F=`echo "$1" | grep -oE "[a-Z0-9\.]+$"`
D=`echo $F | grep -oE "[0-9]+"`
Y=${D:0:4}
M=${D:4:2}
D=${Y}-${M}

for i in $1
do
    LL=`grep -n "______________________________________________________________" $1 | cut -d: -f1`
    T1=`echo "$LL" | head -1`
    T2=`echo "$LL" | tail -1`
    IN_T1=0
    IN_T2=0
    C=0
    DATA=( )
    while read line
    do
        let C=$C+1
        if [ $C -eq $T1 ]
        then
            IN_T1=1
            continue
        elif [ $C -eq $T2 ]
        then
            IN_T2=1
            continue
        elif [ `expr match "$line" "Mean/"` -gt 0 ]
        then
            IN_T1=0
            IN_T2=0
            continue
        fi
        if [ ${IN_T1} -eq 0 ] && [ ${IN_T2} -eq 0 ]
        then
            continue
        fi
        num=`echo "$line" | cut -d"|" -f2 | sed 's/_//g'`
        if [[ ${num} =~ ^[0-9]+$ ]]
        then
            let index=${num}-1
            newline=`echo "${line}" | sed 's/_//g' | sed 's/|-|/||/g' | sed 's/|/,/g' | sed 's/^,//g' | sed 's/,$//g' | sed 's/N\.A\.//g' | sed 's/\^//g' | sed 's/Trace/0/'`
            if [ `echo ${DATA[${index}]} | wc -m` -gt 1 ]
            then
                newline=`echo ${newline} | cut -d, -f2-`
                if [ ${Y} -lt 2005 ]; then newline=",${newline}"; fi
                DATA[${index}]=${DATA[${index}]},${newline}
            else
                V=`echo ${newline} | cut -d, -f1`
                DATA[${index}]=${D}-`printf "%02d" ${V}`,`echo ${newline} | cut -d, -f2-`
            fi
        fi
    done < $1
    for (( i = 0 ; i < ${#DATA[*]} ; i++ ))
    do
        echo ${DATA[${i}]}
    done
done
