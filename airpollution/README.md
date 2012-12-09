Hong Kong Air pollution data
============================

These are scripts to extract air pollution from the Environment Protection Department website.

Description
-----------

* get\_fsp.sh is the wrapper that calls curl to download files and calls extract\_fsp.sh and inserts to a database
* extract\_fsp.sh processes a HTML file for the last 24 hour.
* generate\_records.sql uses data from the database to produce unique latest records for putting somewhere else (like [Fusion Tables](https://www.google.com/fusiontables/DataSource?docid=1yJdri8_uLcrUQe0pENr0VUGhs9vXxTFYLdcPezA)). It is used by another script, where an argument ($1) is replaced by a date for which the CSV should be exported.
* airpollution.sql generates the Postgresql table (schema: epd) to accommodate the data
* fsp\_to\_ft.sh gets a CSV output of the unique date-time records (with the latest snapshot) and sends it to Fusion Tables to our table. Requires a valid token from Google for your Fusion Table.
