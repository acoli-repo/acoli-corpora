#!/bin/bash
# if language-table.xml is not found, create it using local abbreviations and lookup in ISO-639-3 codes
# note that the output needs to be manually validated, hence, we do not overwrite anything
if [ -e language-table.xml ] ; then
	echo found language-table.xml, skipping 1>&2;
else
	echo $0 "crawls the subdirectories for (CES) XML files, retrieves local codes, titles and paths" 1>&2;
	echo "and consults local iso-639.3*tab for getting an iso-639-3 code (needs manual verification, so we don't overwrite" 1>&2;
	
	ISO=`ls iso-639-3*tab | egrep -m 1 'tab'`;
	
	(echo '<vols>';
	
	for file in */*.xml; do
		id=`egrep -m 1 '<language ' $file | sed s/'.*id="\([^"]*\)".*'/'\1'/g;`;
		title=`egrep -m 1 '<h.title' $file | sed s/'<[^>]*>'//g;`;
		title=`echo $title | sed s/'Burmse'/'Burmese'/g;` # ad hoc fixes
		keywords=`echo $title | 
			sed -e s/'Scots Gaelic'/'Scottish Gaelic'/g \
				-e s/'Manx Gaelic'/'Manx'/g | \
			sed -e s/':.*'// -e s/'\[.*\]'//g -e s/'([^)]*)'//g -e s/'[^a-zA-Z]'/'\n'/g | egrep '[A-Z]' | \
			egrep -v 'Testament|Gospel' | \
		egrep '....' `; # some ad hoc fixes, min 4 letters to exclude "The" and abbrevs
		if echo $keywords | egrep -v '.' >&/dev/null; then
			keywords=`echo $title | sed -e s/':.*'// -e s/'\[.*\]'//g -e s/'([^)]*)'//g -e s/'[^a-zA-Z]'/'\n'/g | egrep '[A-Z]' | egrep '...'`; # e.g., Uma, but not NT
		fi;
		keywords=`echo $keywords | sed s/' '/'|'/g;`;
		
		# some more ad hoc fixes
		if echo $keywords | grep 'Greek' | grep 'Modern' >&/dev/null; then id="ell"; fi;
		if echo $keywords | grep 'Greek' | grep -v 'Modern' >&/dev/null; then id="grc"; fi;
		if [ $id = 'lav' ]; then id='lat'; fi;
		if [ $id = 'gls' ]; then id='gla'; fi;
		if echo $title | grep Peshitta >& /dev/null; then 
			id='syc';
			keywords=$keywords'|'Syriac;
		fi;
			# Aramaic language ids in ISO-639 are problematic, the Peshitta is 4th c. CE, hence actually Middle Aramaic/Classical Syriac
		
		isolang=`cat $ISO | egrep -m 1 "^"$id 2>/dev/null | sed -e s/'\t\t*\r*$'//g -e s/'.*\t'//g;`;							# match with ISO-639-3 code
		if echo $isolang | grep '^$' >& /dev/null; then
			isolang=`cat $ISO | sed s/'^[^\t]*\t'// | egrep -m 1 "^"$id | sed -e s/'\t\t*\r*$'//g -e s/'.*\t'//g;`;				# match with ISO-639-2 code
		fi;

		if echo $isolang | egrep $keywords >& /dev/null; then
			if `cat $ISO | egrep -m 1 "^"$id 2>/dev/null | sed -e s/'\t\t*\r*$'//g -e s/'.*\t'//g | egrep '.' >&/dev/null`; then
				# echo local=iso639-3; # ok
				iso=$id;
			else
				# echo local=iso639-2; # ok
				iso=`sed s/'^\([^\t]*\)\t\([^\t]*\)\t'/'\2\t\1\t'/g $ISO | egrep -m 1 "^"$id 2>/dev/null | sed -e s/'^[^\t]*\t\([^\t]*\)\t.*'/'\1'/;`;
			fi;
		else
			if [ 1 -eq `cat $ISO | egrep $keywords 2>/dev/null | wc -l` ]; then 
				# echo language unique;		# ok
				iso=`cat $ISO | egrep -m 1 $keywords 2>/dev/null | sed s/'[^a-z].*'//`;
				isolang=`cat $ISO | egrep -m 1 $keywords 2>/dev/null | sed -e s/'\t*\r*$'//g -e s/'.*\t'//g`;
			else 
				if [ 1 -eq `cat $ISO | egrep $(echo $keywords | sed s/'|'/'\\ '/g)  2>/dev/null | wc -l` ]; then 
					# echo complex language name unique		# not ok
					iso=`cat $ISO | egrep -m 1 $(echo $keywords | sed s/'|'/'\\ '/g) 2>/dev/null | sed s/'[^a-z].*'//`;
					isolang=`cat $ISO | egrep -m 1 $(echo $keywords | sed s/'|'/'\\ '/g) 2>/dev/null | sed -e s/'\t*\r*$'//g -e s/'.*\t'//g`;
				else 
					if [ 1 -eq `cat $ISO | sed -e s/'\t'/'{TAB}'/g |egrep '{TAB}'$keywords'{TAB}' | wc -l` ]; then
						# echo keyword unique and matching; # ok
						iso=`cat $ISO | cat $ISO | sed -e s/'\t'/'{TAB}'/g |egrep '{TAB}'$keywords'{TAB}' | sed s/'{TAB}.*'//`;
						isolang=`cat $ISO | cat $ISO | sed -e s/'\t'/'{TAB}'/g |egrep '{TAB}'$keywords'{TAB}' | sed -e s/'{TAB}'/'\t'/g -e s/'\t*\r*$'// -e s/'.*\t'//g;`;
					else
						iso=`cat $ISO | egrep $keywords 2>/dev/null | sed s/'[^a-z].*'//g | perl -pe 's/[\r\n]+/\|/gs;' | sed s/'|$'//;`;
						isolang=`cat $ISO | egrep $keywords 2>/dev/null | perl -pe 's/\r//g; s/[^\n]*\t([^\t]+)\t*\n/$1|/gs;' | sed s/'|$'//;`;
						echo warning: language ambiguous in 1>&2;
						echo '<vol file="'$file'" iso="'$iso'" local_lang_id="'$id'" title="'$title'" lang="'$isolang'" lang_keywords="'$keywords'"/>' 1>&2;
					fi;
				fi;
			fi;
		fi;
		
		echo '<vol file="'$file'" iso="'$iso'" local_lang_id="'$id'" title="'$title'" lang="'$isolang'" lang_keywords="'$keywords'"/>';
	done;
	echo '</vols>' ) > language-table.xml;
fi;