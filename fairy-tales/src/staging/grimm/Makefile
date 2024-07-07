SHELL=bash

	#cat ../file2khm.tsv | grep khm | sed s/'^\([^\t]*\)\t\([^\t]*\)'/'-e s\/"^\\(.*\\\/\\)\1.md"\/"mv \& \\1\2.md"\/ '/; \

khm_txt: file2khm.tsv txt
	cd txt;\
	for file in `find */`; do \
		if [ -s $$file ]; then \
			tgt=../khm_txt/$$file;\
			if [ ! -e `dirname $$tgt` ]; then mkdir -p `dirname $$tgt`; fi;\
			echo cp $$file $$tgt;\
		fi;\
	done \
	| sed s/'[^ ]*$$'/'`echo & | python3 ..\/rename.py ..\/file2khm.tsv` || echo error 1>\&2;'/ \
	| bash -e

txt: update_txt

update_txt: www.grimmstories.com
	for dir in www.grimmstories.com/*/; do \
		lang=`echo $$dir | cut -f 2 -d '/'`;\
		echo $$dir $$lang 1>&2;\
		if [ ! -e txt/$$lang ]; then mkdir -p txt/$$lang; fi;\
		for file in $$dir/*/*; do \
			tgt=txt/$$lang/`basename $$file`.md;\
			if [ $$lang != 'de' ]; then \
				de_name=`cat $$file \
						| sed -e s/'>'/'>\n'/g -e s/'<'/'\n<'/g \
						| grep '<a ' \
						| sed s/'\s'/'\n'/g \
						| grep href \
						| cut -f 2 -d '=' \
						| cut -f 1 -d '>' \
						| sed -e s/'"'//g -e s/"'"//g \
						| grep -m 1 www.grimmstories.com/de`;\
				tgt=txt/$$lang/`basename $$de_name`.md;\
			fi;\
			\
			if [ ! -s $$tgt ]; then \
				echo $$file '>' $$tgt 1>&2;\
				echo "# author: Gebrüder Grimm";\
				echo "# source: tbc";\
				echo "# url: https://"$$file;\
				echo "# note: copyright of translation tbc";\
				echo; \
				(xmllint \
					--xpath "//div[@class='main']//div[@itemprop='text']/../*[name()='h2' or (name()='div' and @itemprop='text')]" \
					--html $$file 2>/dev/null) \
				| pandoc -f html -t markdown \
				| grep -v ':::' \
				| sed -e s/'{[^}]*}'//g -e s/'\\'//g;\
			fi >> $$tgt;\
		done;\
	done;
	rm -f txt/*/index* txt/*/classification.md txt/*/favorites* txt/*/list.md txt/*/random.md txt/*/titles.md txt/*/audio.md

www.grimmstories.com:
	wget -nc -r -np -l 0 -F \
		 --reject '*.js,*.css,*.ico,*.txt,*.gif,*.jpg,*.jpeg,*.png,*.mp3,*.pdf,*.tgz,*.flv,*.avi,*.mpeg,*.iso' \
		 https://www.grimmstories.com/
	rm www.grimmstories.com/language.php\?grimm\=*

#www.andersenstories.com:
#	wget -nc -r -np -l 0 -F \
#		 --reject '*.js,*.css,*.ico,*.txt,*.gif,*.jpg,*.jpeg,*.png,*.mp3,*.pdf,*.tgz,*.flv,*.avi,*.mpeg,*.iso' \
#		 https://www.andersenstories.com/