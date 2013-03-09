# Hong Kong Gazette Scraper

This a collection of scripts for collecting information in an automated way from the Hong Kong government gazette, an periodical online document containing all government announcements.

## Description of the gazette website

The gazette website is protected from scraping by a session checker that redirects users to a [disclaimer page](http://www.gld.gov.hk/egazette/english/gazette/disclaimer.php) when a user enters the site without a valid session cookie. We use the default table of contents [accept page](http://www.gld.gov.hk/egazette/english/gazette/toc.php?Submit=accept) as a means to obtain a valid cookie for ``curl``.

The strategy is then to go through the hierarchy of gazette summaries, PDF page summaries and ultimately collect the contents PDF files.

## Scripts

* ``callgazettescraper.sh``, as the name indicates, calls ``gazettescraper.sh``. It tries to run ``gazettescraper.sh`` several times and exits when it fails after a number of times.
* ``gazettescraper.sh`` is the main wrapper script that calls the bash and Python scripts responsible for getting and downloading gazette pages.
* Other scripts are described in ``gazettescraper.sh``. They first get the table of contents, then the individual gazette page listings, and then the PDF file listings. Finally, we save the PDFs locally, rename them and obtain a hash for reference. We also save the metadata of the PDFs from the PDF listings pages.
* We also perform a "second-run" on the PDF listings, because some document entities are broken down into several PDF files.

## Database support

* The scripts will output to CSV files, but also insert to a database.
* The database system we use is Postgresql.
* Database support requires a ``mypass.py``, which should have a ``getConn`` function as [the one](https://github.com/JMSCHKU/Social/blob/master/mypass.py) we used for the social media project.
* We provide the dumps of two tables: ``gazette.docs.sql`` is for the docs table, which contains the metadata for a gazette PDF, and ``gazette.pdfs.sql``, is for the pdfs table, which is for the PDF reference, filename and MD5 hash.

## To-do

* Get the Chinese version of the PDFs.
* Indexing and analysis of PDF contents.
