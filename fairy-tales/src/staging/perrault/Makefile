SHELL=bash

wikisource: update_wikisource

update_wikisource:
	if [ ! -e wikisource ]; then mkdir wikisource; fi;\
	cd wikisource;\
	\
	# fr index \
	wget -r -nc -np "https://fr.wikisource.org/wiki/Contes_de_Perrault_(%C3%A9d._1902)";\
	\
	# fr tales \
	tales=`cat fr.wikisource.org/wiki/* \
			| perl -pe 's/\s+/ /g; s/</\n</g;' \
			| grep '<a '\
			| sed s/' '/'\n'/g \
			| grep href \
			| egrep '"/wiki/Contes.*/' \
			| cut -f 2 -d '"'`;\
	for tale in $$tales; do \
		wget -r -nc -np "https://fr.wikisource.org/"$$tale;\
	done;\
	# \
	# inter-language links\
	for fr in `find fr.wikisource.org/*/*`; do \
		links=`cat $$fr \
			   | xmllint --xpath "//li[contains(@class,'interlanguage-link')]/a/@href" --html - 2>/dev/null | cut -f 2 -d '"';`;\
		for link in $$links; do \
			lang=`echo $$link | cut -f 3- -d / | cut -f 1 -d '.';`;\
			tgt=$$lang.wikisource.org/wiki/aligned/`basename $$fr`;\
			echo $$fr $$lang $$link $$tgt 1>&2;\
			if [ ! -e `dirname $$tgt` ]; then mkdir -p `dirname $$tgt`; fi;\
			if [ ! -e $$tgt ]; then wget $$link -O $$tgt; fi;\
		done;\
	done;

txt: update_txt

update_txt: wikisource
	for dir in wikisource/*; do \
		lang=`echo $$dir | cut -f 2 -d / | cut -f 1 -d '.';`; \
		for file in `find $$dir/*/*/*`; do \
			tgt=txt/$$lang/`basename $$file`.md; \
			if [ ! -e `dirname $$tgt` ]; then mkdir -p `dirname $$tgt`; fi;\
			if [ ! -e $$tgt ]; then \
				echo $$file '>' $$tgt 1>&2;\
				(echo "# author: Charles Perrault";\
	             echo "# source:" `xmllint --html --xpath "//title[1]" $$file 2>/dev/null | pandoc -f html -t markdown | perl -pe 's/\s+/ /g;'`;\
	             echo "# url: wikisource.org";\
				 cat $$file \
				 | xmllint --html - --xpath "//div[@class='mw-body-content']//p" 2>/dev/null \
				 | pandoc -f html -t markdown \
				 | grep -v ':::' \
				 | perl -pe 's/([^\n])\n/\1 /g; s/\n/\n\n/g;' \
				 | perl -pe 's/{[^}]*}//g; s/\[[^\[\]]*\]//g; s/\[[^\[\]]*\]//g; s/\\//g;';\
				) > $$tgt;\
			fi;\
		done;\
	done;
	empties=`ls -l txt/*/* | sed s/'  *'/'\t'/g | cut -f 5,9 | egrep -v '^[0-9][0-9][0-9][0-9]' | cut -f 2`;\
	for file in $$empties; do \
		echo rm $$file empty 1>&2;\
		rm $$file;\
	done;
	rmdir txt/* 2>/dev/null || echo -n '' 2>&1;

restruct_txt: file2id.tsv txt
	cd txt;\
    for file in `find */`; do \
    	if [ -s $$file ]; then \
        	tgt=../restruct_txt/$$file;\
            if [ ! -e `dirname $$tgt` ]; then mkdir -p `dirname $$tgt`; fi;\
            echo cp $$file $$tgt;\
       	fi;\
    done \
    | sed s/'[^ ]*$$'/'`echo & | python3 ..\/..\/grimm\/rename.py ..\/file2id.tsv` || echo error 1>\&2;'/ \
    | bash -e
