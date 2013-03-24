#!/bin/bash

mv all.gazette.*.csv allgazette

D=`date +%Y%m%d-%H%M%S`

SQL="\\copy (select d.*, p.*, 'http://data.jmsc.hku.hk/hongkong/gazette/pdfs/'||filename archive_url from gazette.docs d left join gazette.pdfs p on d.link = p.link order by dept, gazdate) to 'all.gazette.${D}.csv' csv header "

psql -h 127.0.0.1 -U opengov -c "${SQL}"

rm all.gazette.csv

ln -s all.gazette.${D}.csv all.gazette.csv
