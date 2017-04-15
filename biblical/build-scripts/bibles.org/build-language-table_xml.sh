#!/bin/bash
# convert languages-table.csv to an XML file
if [ -e language-table.csv ]; then
	(echo '<vols>';
	sed s/'#.*'//g language-table.csv | \
	egrep '[a-zA-Z0-9]' | \
	sed -e s/'^[^;]*[\\\/]'//g \
		-e s/'\.[^;]*;'/';'/g \
		-e s/'^\([^;\\\/]*\);\([^;]*\);\([^;]*\);.*'/'<vol file="\1" iso="\2" lang="\3"\/>'/g | \
	grep '<';
	echo '</vols>' ) > language-table.xml;
else
	echo build language-table.csv first 1>&2;
fi;
