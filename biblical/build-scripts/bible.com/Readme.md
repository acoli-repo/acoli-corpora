# Crawler for bible.com

bible.com is an aggregator portal for Bibles in currently 1973 languages. Obviously, it incorporates most data from the 2012 (and later) aggregator portals, but it also provides additional data. As we don't have copyright clearance, we provide build scripts, not the data itself.

Run with

	make xml

Retrieval, TSV extraction and XML/CES generation tested for language aai.

TODOs:
- extract and include metadata
- run all over

Note:
- bible.com seems to supersede and incorporate information from most earlier Bible aggregator portals. However, we don't have copyright clearance, so the old data is still valuable because its copyright protection expires much earlier.
- the language table is incomplete, so `retrieve-by-nr.sh` provides an alternative mode of retrieval, where only the version number is to be provided (e.g., 455 or 3223). At the moment, we cannot retrieve the language code in this manner, but in case we can, this method should replace the current implementation in `Makefile`.  