#!/bin/bash
# update license information from accompanying html files
echo "synopsis: $0 DIR[1..n]" 1>&2
echo "   DIRi directory with a bible as created by get-unbound-bibles.sh" 1>&2;
echo "apply post corrections for all xml files: add copyright information, update iso639 language codes," 1>&2;
echo "create a zip archive of the original data" 1>&2;
echo 1>&2;

# (0) prepare language list
if [ ! -e language-table.xml ]; then 
	./build-language-table_xml.sh;
fi;

for dir in $*; do
	echo processing $dir 1>&2;
	if [ -d $dir ]; then
		HTML=$dir/$dir.html;
		XML=`ls $dir/$dir*xml | grep -m 1 'xml'`;
		if [ -e $HTML ]; then 

			TMP=$XML.tmp;
			if [ -e $TMP ]; then rm $TMP; fi;
		
			# (1) prepare 
			# (1.a) zip archive
			mkdir $dir/zips >&/dev/null;
			mod_date=`stat --format='%y' $dir/$dir*xml | sort -nr | egrep -m 1 '[0-9]' | sed s/' .*'//g`;
			ZIP=$dir/zips/$dir-$mod_date.zip;
			if [ -e $ZIP ]; then
				zip -u $ZIP $dir/*.*;
			else 
				zip $ZIP $dir/*.*;
			fi;
			
			# (1.b) retrieve metadata
			iso=`grep -m 1 $XML language-table.xml | sed s/'.* iso="\([^"]*\)".*'/'\1'/g;`
			lang=`grep -m 1 $XML language-table.xml | sed -e s/'.* lang="\([^"]*\)".*'/'\1'/g -e s/' '/'_'/g;`
			
			title=`cat $HTML | perl -pe 's/[\n\r \t]+/ /gs; s/(<\/[^>]*>)/$1\n/g;' | grep -m 1 '<b>' | sed s/'<[^>]*>'//g;` # not directly used (already in)
			year=`echo $title | sed s/'[^0-9]'/'\n'/g | egrep '[0-9]' | egrep -m 1 ....`;
			if echo $year | egrep -v '.' >&/dev/null; then year=Unknown; fi;

			## copyright (below, we just use the full file)
			# cat $HTML | perl -pe 's/[\n\r \t]+/ /gs; s/(<\/[^>]*>)/$1\n/g;' | grep -v '<body' | w3m -T text/html -O utf-8 -dump;
			
			# (2) add copyright, source and language information
			(egrep -B 9999999 -m 1 '<availability' $XML;
			echo -n $HTML:' ';
			w3m -O utf-8 -dump $HTML;
			echo;
			egrep -A 9999999 -m 1 '<availability' $XML | grep -v '<availability' | \
			egrep -B 9999999 -m 1 '<projectDesc';
			echo -n $HTML:' ';
			w3m -O utf-8 -dump $HTML;
			echo;
			egrep -A 9999999 -m 1 '<availability' $XML | \
			egrep -A 9999999 -m 1 '<projectDesc' | grep -v '<projectDesc';) | \
			\
			sed -e s/'\(<language .*iso639="\)TOCHECK\("[^>]*>\)[^<]*\(<\/language>\)'/'\1'$iso'\2'$lang'\3'/g \
				-e s/'\(<language[^>]*>[^<_]*\)_'/'\1 '/g \
				-e s/'\(<language[^>]*>[^<_]*\)_'/'\1 '/g \
				-e s/'\(<language[^>]*>[^<_]*\)_'/'\1 '/g \
				-e s/'\(<language[^>]*>[^<_]*\)_'/'\1 '/g \
				-e s/'\(<language[^>]*>[^<_]*\)_'/'\1 '/g \
				-e s/'\(<language[^>]*>[^<_]*\)_'/'\1 '/g \
				-e s/'\(<language[^>]*>[^<_]*\)_'/'\1 '/g \
				-e s/'\(<language[^>]*>[^<_]*\)_'/'\1 '/g \
				-e s/'\(<language[^>]*>[^<_]*\)_'/'\1 '/g \
				-e s/'\(<language[^>]*>[^<_]*\)_'/'\1 '/g \
				-e s/'\(<language[^>]*>[^<_]*\)_'/'\1 '/g \
				-e s/'\(<language[^>]*>[^<_]*\)_'/'\1 '/g \
				-e s/'\(<language[^>]*>[^<_]*\)_'/'\1 '/g \
				-e s/'<writingSystem[^>]*>[^<]*<[^>]*>'/'<writingSystem id="utf-8">Unicode<\/writingSystem>'/g \
				-e s/'<pubDate>Unknown<\/pubDate>'/'<pubDate>'$year'<\/pubDate>'/g \
			> $TMP;
			
			# (4) pruning: remove the original files, keeping only $TMP
			for file in `unzip -l $ZIP | egrep '^[ \t]*[0-9]' | grep $dir | sed s/'.*[ \t]'//g;`; do
				zip -m $ZIP $file;
			done;
			
			# (5) mv $TMP to $XML;
			mv $TMP $XML;

		else # if processed already
			echo file $HTML not found, skipping $dir 1>&2;
		fi;
	else
		echo $dir should be a directory, skipping $dir 1>&2;
	fi;
	echo 1>&2;
done;