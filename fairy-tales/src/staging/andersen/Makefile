SHELL=bash

txt: update_txt

update_txt: www.andersenstories.com
	for dir in www.andersenstories.com/*/; do \
		lang=`echo $$dir | cut -f 2 -d '/'`;\
		echo $$dir $$lang 1>&2;\
		if [ ! -e txt/$$lang ]; then mkdir -p txt/$$lang; fi;\
		for file in $$dir/*/*; do \
			tgt=txt/$$lang/`basename $$file`.md;\
			if [ $$lang != 'da' ]; then \
				da_name=`cat $$file \
						| sed -e s/'>'/'>\n'/g -e s/'<'/'\n<'/g \
						| grep '<a ' \
						| sed s/'\s'/'\n'/g \
						| grep href \
						| cut -f 2 -d '=' \
						| cut -f 1 -d '>' \
						| sed -e s/'"'//g -e s/"'"//g \
						| grep -m 1 www.andersenstories.com/da`;\
				tgt=txt/$$lang/`basename $$da_name`.md;\
			fi;\
			\
			if [ ! -s $$tgt ]; then \
				echo $$file '>' $$tgt 1>&2;\
				echo "# author: Hans Christian Andersen";\
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

www.andersenstories.com:
	wget -nc -r -np -l 0 -F \
		 --reject '*.js,*.css,*.ico,*.txt,*.gif,*.jpg,*.jpeg,*.png,*.mp3,*.pdf,*.tgz,*.flv,*.avi,*.mpeg,*.iso' \
		 https://www.andersenstories.com/
	rm www.andersenstories.com/language.php\?*

alm:
	if [ ! -e alm ]; then \
		mkdir alm;\
		cd alm;\
		wget http://people.rc.rit.edu/~coagla/affectdata/HCAndersen.tar.gz;\
		tar -xvf HCAndersen.tar.gz;\
	fi;

restruct_txt: alm2id.tsv txt alm
	cd txt;\
    for file in `find */`; do \
        if [ -s $$file ]; then \
                tgt=../restruct_txt/$$file;\
            if [ ! -e `dirname $$tgt` ]; then mkdir -p `dirname $$tgt`; fi;\
            cp $$file $$tgt || echo error 1>&2;\
        fi;\
    done;

	for file in alm/HCAndersen/sent/*; do \
		if [ -s $$file ]; then \
            tgt=restruct_txt/en/`basename $$file | cut -f 1 -d '.'`.1867.md;\
            if [ ! -e `dirname $$tgt` ]; then mkdir -p `dirname $$tgt`; fi;\
            (echo '# author:' Hans Christian Andersen;\
        	 echo '# source:' "Hans Christian Andersen (1867), Hans Andersen's fairy tales, a new tr. by Mrs. Paull. With a Special Adaptation and Arrangement for Young People, Frederick Warne & Co./London; Scribner & Co/New York";\
			 echo '# url: http://people.rc.rit.edu/~coagla/affectdata/index.html';\
			 echo '# note: source heuristically identified';\
			 echo;\
			) > $$tgt;\
            echo cat $$file '>>' $$tgt;\
        fi;\
    done \
    | sed s/'[^ ]*$$'/'`echo & | python3 ..\/grimm\/rename.py alm2id.tsv` || echo error 1>\&2;'/ \
    | bash -e
