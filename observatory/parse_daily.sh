#!/bin/bash

for i in $1
do
    DATE="`echo $1 | cut -d. -f1 | grep -oE "[0-9\-]+$"`"
    MAXTEMP="`grep -i "maximum air temp" $i | head -1`"
    MINTEMP="`grep -i "minimum air temp" $i | head -1`"
    GRASSTEMP="`grep -i "grass minimum temp" $i | head -1`"
    RELHUM="`grep -i "relative humidity" $i | head -1`"
    RAINFALL="`grep -i "rainfall" $i | head -1`"
    iMAXTEMP=`echo "$MAXTEMP" | grep -oE " {2,}(.*)$" | sed 's/^ *//g' | sed 's/ *$//g' | sed 's/ C//' | sed 's/[\r\n]*//g'`
    iMINTEMP=`echo "$MINTEMP" | grep -oE " {2,}(.*)$" | sed 's/^ *//g' | sed 's/ *$//g' | sed 's/ C//' | sed 's/[\r\n]*//g'`
    iGRASSTEMP=`echo "$GRASSTEMP" | grep -oE " {2,}(.*)$" | sed 's/^ *//g' | sed 's/ *$//g' | sed 's/ C//' | sed 's/[\r\n]*//g'`
    iRELHUM=`echo "$RELHUM" | grep -oE " {2,}(.*)$" | sed 's/ *//g' | sed 's/percent//i' | sed 's/[\r\n]*//g' | sed 's/-/,/'`
    iRAINFALL=`echo "$RAINFALL" | grep -oE " {2,}(.*)$" | sed 's/^ *//g' | sed 's/ *$//g' | sed 's/ mm//i' | sed 's/[\r\n]*//g'`
    echo "$DATE,$iMAXTEMP,$iMINTEMP,$iGRASSTEMP,$iRELHUM,$iRAINFALL"
done
