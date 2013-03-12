#!/bin/bash

for i in `seq 2006 2014`
do
    echo $i
    psql -h 127.0.0.1 -U opengov -c "alter table budget.revenues add column actual${i} integer"
    psql -h 127.0.0.1 -U opengov -c "alter table budget.revenues add column approved${i} integer"
    psql -h 127.0.0.1 -U opengov -c "alter table budget.revenues add column revised${i} integer"
    psql -h 127.0.0.1 -U opengov -c "alter table budget.revenues add column estimate${i} integer"    
done
