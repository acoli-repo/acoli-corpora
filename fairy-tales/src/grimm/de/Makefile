1857:
	@author="Gebrüder Grimm";\
	source="Gebrüder Grimm (1852), Kinder- und Haus-Märchen, Band 1+2, Große Ausgabe. 7. Auflage (Ausgabe letzter Hand), Dieterich, Göttingen";\
	urls="https://de.wikisource.org/wiki/Kinder-_und_Haus-M%C3%A4rchen_Band_1_(1857) https://de.wikisource.org/wiki/Kinder-_und_Haus-M%C3%A4rchen_Band_2_(1857)";\
	note="de.wikisource.org";\
	year=1857;\
	nr2paths=$$(\
		for url in $$urls; do \
			wget $$url -O - 2>/dev/null \
			| perl -pe 's/\s+/ /g; s/</\n</g; s/>/>\n/g;' \
			| sed s/' '/'\n'/g \
			| grep href \
			| grep '#Seite' \
			| cut -f 2 -d '"' \
			| cut -f 1 -d '#'; \
		done \
		| egrep -n .; \
	);\
	for nr2path in $$nr2paths; do \
		nr=`echo $$nr2path | cut -f 1 -d ':'`;\
		nr=`echo 0000$$nr | sed s/'^0*\([0-9][0-9][0-9]\)$$/\1/g;'`;\
		tgt=khm-$$nr.$$year.md;\
		path=`echo $$nr2path | cut -f 2- -d ':'`;\
		url=`echo $$urls | cut -f 1-3 -d '/'`;\
		if [ ! -e $$tgt ]; then \
			echo $$url$$path '>' $$tgt 1>&2;\
			echo '# author: '$$author;\
			echo '# source: '$$source;\
			echo '# url: '$$url$$path;\
			echo '# note: '$$note;\
			wget $$url$$path -O - 2>/dev/null \
			| perl -pe 's/>/>\n/;' \
			| xmllint -html -format -xpath "//div[@style='display:table; text-align:justify; text-indent:0px; padding-left:10px; padding-right:10px;']" - 2>/dev/null \
			| pandoc -f html - -t markdown \
			| grep -v ':::' \
			| perl -pe 's/\\\n/ /g;' \
			| perl -pe 's/([^\s])\n/\1 /g; s/\n/\n\n/g;' \
			| perl -pe 'while(m/.*\{[^\{\}]*\}.*/) { s/\{[^\{\}]*\}//g; };' \
			| perl -pe 'while(m/.*\[[^\[\]]*\].*/) { s/\[[^\[\]]*\]//g; };' \
			| perl -pe 's/^\*\*([^\n]*)\*\*\s+/# title: \1\n\n/g;' \
			| grep -P '[^\s]' \
			| perl -pe 's/\n/\n\n/g';\
		fi >> $$tgt;\
	done;\
	if [ ! -e ../nds ]; then mkdir ../nds; fi;\
	for file in `grep -l ' dat ' khm*`; do \
		echo $$file '>' ../nds 1>&2; \
		mv $$file ../nds; \
	done;\