1884:
	@author="Gebrüder Grimm";\
	source="Grimm's Household Tales, volume 1 and volume 2 (1884), translated by Margaret Raine Hunt; complete translation of the 1857 German edition";\
	urls="https://en.wikisource.org/wiki/Grimm%27s_Household_Tales,_Volume_1 https://en.wikisource.org/wiki/Grimm%27s_Household_Tales,_Volume_2";\
	note="en.wikisource.org";\
	year=1884;\
	nr2paths=$$(\
		for url in $$urls; do \
			wget $$url -O - 2>/dev/null \
			| perl -pe 's/\s+/ /g; s/</\n</g; s/>/>\n/g;' \
			| sed s/' '/'\n'/g \
			| grep href \
			| egrep 'Volume.*/.*' \
			| grep -v '/Introduction' \
			| grep -v '/Notes' \
			| cut -f 2 -d '"'; \
		done \
		| egrep -n .; \
	);\
	for nr2path in $$nr2paths; do \
		nr=`echo $$nr2path | cut -f 1 -d ':'`;\
		nr=`echo 0000$$nr | sed s/'^0*\([0-9][0-9][0-9]\)$$/\1/g;'`;\
		tgt=khm-$$nr.$$year.md;\
		path=`echo $$nr2path | cut -f 2- -d ':'`;\
		url=`echo $$urls | cut -f 1-3 -d '/'`;\
		if [ ! -s $$tgt ]; then \
			echo $$url$$path '>' $$tgt 1>&2;\
			echo '# author: '$$author;\
			echo '# source: '$$source;\
			echo '# url: '$$url$$path;\
			echo '# note: '$$note;\
			wget $$url$$path -O - 2>/dev/null \
			| perl -pe 's/>/>\n/;' \
			| xmllint -html -format -xpath "//div[@class='prp-pages-output']" - 2>/dev/null \
			| perl -pe 'while(m/.*<[\/]*span( [^>]*)\s*>.*/) { s/<[\/]*span( [^>]*)\s*>//g; };' \
			| pandoc -f html - -t markdown \
			| grep -v ':::' \
			| perl -pe 's/\\\n/ /g;' \
			| perl -pe 's/([^\s])\n/\1 /g; s/\n/\n\n/g;' \
			| perl -pe 'while(m/.*\{[^\{\}]*\}.*/) { s/\{[^\{\}]*\}//g; };' \
			| perl -pe 'while(m/.*\[[^\[\]]*\].*/) { s/\[[^\[\]]*\]//g; };' \
			| perl -pe 's/^([0-9][^a-z\n]+)\n/# title: \1\n\n/g;' \
			| egrep -v '^[^a-z]*$$' \
			| perl -pe 's/\n/\n\n/g'\
			| perl -pe 's/\-\-+/ /g;'\
			| sed s/'\\'//g;\
		fi >> $$tgt;\
	done;\
	rm khm-212*;
