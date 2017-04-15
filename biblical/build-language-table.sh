#!/bin/bash
# retrieves all (CES) XML files from data and all language-table.xml files from build-scripts, generate statistics
(
echo '<?xml-stylesheet type="text/xsl" href="language-table.xsl"?>';
echo '<vols>';
(for file in `find data | grep '.xml'`; do
	if [ -s $file ]; then
		lang=`cat $file | perl -pe 's/\n//g; s/</\n</g;' | grep -m 1 '<language' | sed s/'<[^>]*>'//g;`
		iso639=`cat $file | perl -pe 's/\n//g; s/</\n</g;' | grep -m 1 '<language' | sed s/'.*iso639="\([^"]*\)".*'/'\1'/g;`
		availability=`cat $file | perl -pe 's/\n//g; s/</\n</g;' | grep -m 1 '<availability' | sed s/'.*status="\([^"]*\)".*'/'\1'/g;`
		title=`cat $file | perl -pe 's/\n//g; s/</\n</g;' | grep -m 1 '<h.title' | sed s/'<[^>]*>'//g;`
		date=`cat $file | perl -pe 's/\n//g; s/</\n</g;' | egrep -A 9999 '<sourceDesc' | grep -m 1 '<pubDate' | sed -e s/'[^0-9]'/'\n'/g | grep -m 1 '^[0-9][0-9][0-9][0-9]$'`
		tok=`cat $file | perl -pe 's/\n//g; s/<seg/\n<seg/g;' | grep '<seg' | sed s/'<[^>]*>'/' '/g | wc -w`;
		echo '<vol iso="'$iso639'" availability="'$availability'" lang="'$lang'" file="'$file'" date="'$date'" title="'$title'" tok="'$tok'"/>';
	fi;
done;
for file in `find build-scripts | grep 'language-table.xml' | grep -v '.xml.'`; do
	# echo $file;
	#cat $file;
	#echo extract from $file;
	file_esc=`echo $file | sed s/'\/'/'\\\/'/g;`
	cat $file | \
	perl -pe 's/\n/ /g; s/</\n</g;' | \
	grep '<vol ' | \
	perl -e '
		while(<>) {
			print "<vol iso=\"";
			my $iso639=$_; $iso639=~s/.*iso="([^"]*)".*\n/$1/g; print $iso639;
			print "\" availability=\"locally reproducible\" lang=\"";
			my $lang=$_; $lang=~s/.*lang="([^"]*)".*\n/$1/g; print $lang;
			print "\" file=\"";
			print "'`echo $file`'#";
			my $file=$_; $file=~s/.*file="([^"]*)".*\n/$1/g; print $file;
			print "\"/>\n";
		};
		';
done 2>/dev/null | egrep '<vol.*>' ) | sort;
echo '</vols>';) > language-table.xhtml;