#!/bin/bash
# retrieves all bibles from http://unbound.biola.edu/index.cfm?method=downloads.showDownloadMain
echo check available versions 1>&2;
VERSION_IDS=`wget http://unbound.biola.edu/index.cfm?method=downloads.showDownloadMain -O - | \
			grep -A 1 "<select name='version_download'>" | sed s/'>'/'>\n'/g | \
			grep '<option value' | sed -e s/'.*value=.'// -e s/'_ucs2.*'// -e s/'[^a-zA-Z_0-9].*'//`;
for dir in $VERSION_IDS; do
	if mkdir $dir >&/dev/null; then
		cd $dir;
			wget http://unbound.biola.edu/downloads/bibles/$dir.zip
			unzip $dir.zip;
			rm $dir.zip;
		cd ..;
	else
		echo found directory $dir, skipping 1>&2;
	fi;
done;