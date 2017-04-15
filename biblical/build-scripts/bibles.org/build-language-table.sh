#!/bin/bash
# argument are files, we assume that the first three letters of the file name (without path) represent an ISO 639-3 code
# this is looked up in lexvo
# write table to stdout
echo '#file;iso639-3;language';
for file in $*; do
	code=`echo $file|sed -e s/'.*\/'//g -e s/'^\(...\).*'/'\1'/`;
	echo $code 1>&2;
	lang=`w3m -dump_source http://www.lexvo.org/page/iso639-3/$code | xmllint --html --recover - 2>/dev/null | egrep -B 1 -A 1 'rdfs:label' | egrep -m 1 -A 2 'span lang="en"' | \
	grep -v "rdfs:label" | \
	sed -e s/'<[^>]*>'// -e s/'([^)]*)'// -e s/'[(<].*'//g -e s/'.*[)>]'//g -e s/'\t'/' '/g -e s/'^  *'// -e s/'  *$'// | grep -v '^$'`;
	echo $file';'$code';'$lang;
done;