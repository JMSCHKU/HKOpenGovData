#!/bin/bash

for i in $1
do
    #echo $i
    H=`grep -Eni "<pre>" $i | head -1 | cut -d: -f1`
    T=`grep -Eni "</pre>" $i | tail -1 | cut -d: -f1 `
    WC=`wc -l $i | cut -d" " -f1`
    let D=${T}-${H}
    let D=${D}+1
    #echo $D $T $WC
    head -${T} $i | tail -${D}
done
