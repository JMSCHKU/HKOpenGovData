#!/bin/bash

for i in `seq 2006 2014`
do
    echo $i
    psql -h 127.0.0.1 -U opengov -c "alter table budget.expenditures add column actual${i} integer"
    psql -h 127.0.0.1 -U opengov -c "alter table budget.expenditures add column approved${i} integer"
    psql -h 127.0.0.1 -U opengov -c "alter table budget.expenditures add column revised${i} integer"
    psql -h 127.0.0.1 -U opengov -c "alter table budget.expenditures add column estimate${i} integer"    
done
