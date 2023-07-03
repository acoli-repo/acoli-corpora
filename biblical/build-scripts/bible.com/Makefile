SHELL=bash

all: html tsv xml

html: langs.txt
	if [ ! -e html ]; then \
		mkdir html;\
		for lang in `cut -f 1 langs.txt`; do \
			echo $$lang 1>&2; \
			tgtdir=html/`echo $$lang | sed s/'.*\/'//g`;\
			mkdir $$tgtdir;\
			wget https://www.bible.com/$$lang -O $$tgtdir/index.html;\
			versions=`\
				cat $$tgtdir/index.html \
				| perl -pe 's/\s+/\n/g;' \
				| grep href= \
				| grep '/versions/' \
				| sed s/"'"/'"'/g \
				| cut -f 2 -d '"';\
			`;\
			for version in $$versions; do \
				vdir=$$tgtdir/`echo $$version | sed s/'.*\/'//g;`; \
				if [ ! -e $$vdir ]; then \
					mkdir -p $$vdir;\
					wget https://www.bible.com/$$version -O $$vdir/index.html;\
					chap=`cat $$vdir/index.html \
						| perl -pe 's/\s+/\n/g; ' \
						| grep href \
						| sed s/"'"/'"'/g \
						| cut -f 2 -d '"' \
						| grep -m 1 '/bible/'`; \
					wget https://www.bible.com/$$chap -O $$vdir/tmp.html; \
					echo > $$vdir/bib.tsv;\
					while [ -e $$vdir/tmp.html ]; do \
						cat $$vdir/tmp.html \
						| perl -pe 's/\s+/ /g; s/(<span data-usfm="([A-Z0-9]+\.[0-9]+\.[0-9]+)")/\nb.\2\t\1/g; s/<\/div/\n<\/div/g;' \
						| grep -P '\t<span' \
						>> $$vdir/bib.tsv;\
						chap=`cat $$vdir/tmp.html \
							| perl -pe 's/<a/\n<a/g;' \
							| grep '<a' \
							| grep href \
							| grep -i 'Next Chapter' \
							| sed s/'^[^>]*href'//g \
							| sed s/"'"/'"'/g \
							| cut -f 2 -d '"' \
							| grep '/bible/' -m 1`;\
						rm $$vdir/tmp.html;\
						if wget https://www.bible.com/$$chap -O $$vdir/tmp.html; then \
							echo $$chap 1>&2;\
						else \
							rm $$vdir/tmp.html;\
							break;\
						fi;\
					done;\
					if [ -e $$vdir/tmp.html ]; then rm $$vdir/tmp.html; fi; \
				fi;\
			done;\
			exit 1;\
		done; \
	fi;

tsv: html
	cd html;\
	for lang in */; do \
		for version in $$lang/*/; do \
			tgtdir=../tsv/$$version;\
			if [ ! -e $$tgtdir ]; then mkdir -p $$tgtdir; fi; \
			for bib in $$version/*.tsv; do \
				if [ -e $$bib ]; then \
					tgt=../tsv/$$bib; \
					if [ ! -s $$tgt ] ; then \
						echo html/$$bib '>' tsv/$$bib 1>&2;\
						cat $$bib \
						| perl -pe 's/<span class="[^"]*ChapterContent_(label|note|x|body__Iyd1D)[^"\n\t]*"[^>]*>[^<]*<\/span>/ /g;' \
						| perl -pe 's/<[^>]*>//g; s/<.*//g; s/[^\t\n]*>//g;'\
						| perl -e ' while(<>) { while(m/\t[^\n0-9]*[0-9]([0-9\.]*[0-9])?/) { s/(\t[^\n0-9]*)[0-9]([0-9\.]*[0-9])?/\1/g; } print; };' \
						| perl -pe 's/ +/ /g; s/ *\t */\t/g; s/ *\n/\n/g;' \
						| grep -P '\t[^\s]' \
						> $$tgt;\
					fi;\
				fi;\
			done;\
		done;\
	done;

xml: tsv
	cd tsv; \
	for lang in */; do \
		tgtdir=../xml/$$lang;\
		for version in $$lang/*; do \
			for bib in $$version/*.tsv; do \
				if [ -e $$bib ]; then \
					if [ ! -e $$tgtdir ]; then mkdir -p $$tgtdir; fi; \
					tgt=$$tgtdir/`basename $$version`.xml;\
					if [ ! -s $$tgt ] ; then \
						echo tsv/$$bib '>' xml/$$lang/`basename $$tgt` 1>&2; \
						python3 ../../../tools/tsv2ces.py $$bib > $$tgt;\
					fi;\
				fi;\
			done;\
		done;\
	done;


langs.txt: langs
	if [ ! -s langs.txt ]; then \
		for doc in langs/*html; do \
			cat $$doc \
			| perl -pe 's/\s+/ /g; s/(<\/)/\n\1/g; s/<a/\n<a/g;' \
			| grep '<a' \
			| grep '/languages/' \
			| perl -pe 's/.*href=.(\/languages\/[a-z]+)[^a-z]?.*>([^<>]+)$$/\1\t\2/g;'; \
		done | \
		sort -u > langs.txt;\
	fi;

langs:
	if [ ! -e langs ]; then \
		mkdir langs;\
		for i in {1..500}; do \
			echo $$i;\
			tgt=`echo 000$$i | sed s/'.*\(....\)$$'/'\1'/g;`; \
			tgt=langs/$$tgt.html;\
			src="https://www.bible.com/languages?page="$$i;\
			echo $$src '>' $$tgt 1>&2; \
			if wget $$src -O $$tgt; then \
				echo langs/$$tgt.html ok 1>&2;\
			else \
				rm $$tgt; \
				break;\
			fi;\
		done;\
	fi;\

