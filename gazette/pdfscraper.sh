#!/bin/bash

if [ $# -lt 1 ]
then
    echo "Missing file with PDF links"
    exit
fi

echo "link,filename,filehash" > $1.out
./getpdfs.sh $1 >> $1.out
./insert_by_row.py gazette.pdfs $1.out
