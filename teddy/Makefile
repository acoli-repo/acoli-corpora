SHELL=bash

all: vtt txt tok core

# removes all generated directories and runs make from scratch
# this is useful to update previously downloaded TED talks with new subtitles, these aren't retrieved otherwise
rebuild:
	for dir in vtt vtt_yt txt; do \
		if [ -e $$dir ]; then rm -rf $$dir; fi; \
	done
	make

######################
# subtitle retrieval #
######################

# make update_sources will always iterate over all TED talks
# make vtt will do that only if the vtt/ directory is not found
# by default, we do make vtt, use make update_sources to trigger
# update/full retrieval
vtt:
	if [ ! -e vtt/ ]; then make update_sources; fi

# retrieve TED subtitles from Youtube
# this works, but only a small portion of TED data is available from Youtube
# not recommended for production use, but this is a fallback in case TED extraction fails
# e.g. if their website is updated
youtube:
	if [ ! -e vtt_yt ]; then mkdir vtt_yt; fi
	cd vtt_yt;\
	youtube-dl -i --skip-download --console-title --all-subs --sub-format vtt  https://www.youtube.com/user/TEDxTalks

# retrieve TED subtitles from TED.com
# note that we don't update TED talks that have been previously retrieved, to update these, run make rebuild
# note that we only retrieve the first segment per vtt file
update_sources:
	if [ ! -e vtt ]; then mkdir vtt; fi
	for file in {0..9999}; do \
		src=https://hls.ted.com/project_masters/$$file;\
		echo -n $$src 1>&2;\
		if [ -e vtt/$$file ]; then \
			echo ' found' 1>&2;\
		else \
			mkdir vtt/$$file;\
			subs=$$(\
				wget -nc $$src/manifest.m3u8 -O - 2>/dev/null | \
				grep -i SUBTITLES | \
				grep -i URI | \
				sed s/'.*,URI'//g | \
				cut -f 2 -d '"' | \
				grep m3u8 | \
				sed s/'\.m3u8'/'.vtt'/g;\
			);\
			for sub in $$subs; do \
				wget -nc https://hls.ted.com/project_masters/$$file/$$sub -O vtt/$$file/`basename $$sub` 2>/dev/null;\
			done;\
			for dir in vtt/$$file/; do \
				if echo `grep -l "Sorry, we could not find subtitles" $$dir/*` | egrep -m 1 . >&/dev/null; then \
					rm `grep -l "Sorry, we could not find subtitles" $$dir/*`; \
					echo -n $$dir' ' 1>&2; \
					if rmdir vtt/$$file 2>/dev/null; then echo ' empty' 1>&2; else echo ' '; ls vtt/$$file | perl -pe 's/\s/ /g; s/\.vtt//g;' 1>&2; echo 1>&2; fi;\
				fi;\
			done;\
			if rmdir vtt/$$file 2>/dev/null; then echo ' empty' 1>&2; else echo ' '; ls vtt/$$file | perl -pe 's/\s/ /g; s/\.vtt//g;' 1>&2; echo 1>&2; fi;\
		fi;\
	done;
	make update_segments

# automatically called after make update_sources
update_segments: vtt
	for dir in vtt/*/; do \
		if echo `grep -l "Sorry, we could not find subtitles" $$dir/*` | egrep -m 1 . >&/dev/null; then \
			rm `grep -l "Sorry, we could not find subtitles" $$dir/*`; \
			echo -n $$dir' ' 1>&2; \
			if rmdir vtt/$$file 2>/dev/null; then echo ' empty' 1>&2; else echo ' '; ls vtt/$$file | perl -pe 's/\s/ /g; s/\.vtt//g;' 1>&2; echo 1>&2; fi;\
		fi;\
	done;\
	for sub in vtt/*/*vtt; do \
		if [ ! -e $$sub.1 ]; then \
			nr=`echo $$sub | cut -f 2 -d '/'`;\
			for seg in {1..9999}; do \
				wget -nc https://hls.ted.com/project_masters/$$nr/subtitles/`basename $$sub`'?segment='$$seg -O $$sub.$$seg 2>/dev/null;\
				if cat $$sub.$$seg | grep -v '^00:00:00.000' | grep -v 'Sorry, we could not find subtitles' | grep -m 1 '\-\->' >/dev/null; then \
					echo $$sub.$$seg;\
				else \
					rm $$sub.$$seg;\
					break;\
				fi;\
			done;\
		fi;\
	done;\

###################
# text extraction #
###################

txt: vtt
	if [ ! -e txt ]; then mkdir txt; fi
	cd vtt; \
	for dir in *; do \
		if [ -d $$dir ]; then \
			cd $$dir;\
			langs=`echo *.vtt | perl -pe 's/\s+/\n/g;' | cut -f 1 -d '.'`;\
			for lang in $$langs; do \
				tgt_dir=../../txt/$$lang;\
				if [ ! -e $$tgt_dir ]; then mkdir -p $$tgt_dir; fi; \
				files=`echo $$lang.vtt* | perl -pe 's/\s/\n/g;' | sort | perl -pe 's/^([^\t]*\.vtt\.([0-9]+))$$/\2\t\1/; s/^([^0-9].*\.vtt)$$/1\t\1/g;' | sort -n | cut -f 2`;\
				tgt=$$tgt_dir/$$dir.txt;\
				for file in $$files; do \
					echo $$dir/$$lang/$$file '>>' txt/$$lang/$$dir.txt 1>&2; \
					cat $$file; \
					echo;\
				done | \
				grep -v '^WEBVTT$$' | \
				# to remove duplicate lines: \
				awk '!seen[$$0]++' | \
				grep -v '\-\->' | \
				egrep . | \
				perl -pe 's/\s+/ /g; s/([!?.]["'"'"'\)]*)$$/\1\n/; s/([!?.]["'"'"'\)]*) ([\"\(]*[A-Z])/\1\n\2/g;' > $$tgt;\
			done;\
			cd ..;\
		fi;\
	done;\

#######################################
# sentence splitting and tokenization #
#######################################
# conservative whitespace tokenization

tok: txt
	if [ ! -e tok ]; then mkdir tok; fi
	cd txt;\
	for lang in */; do \
		if [ ! -e ../tok/$$lang ]; then mkdir ../tok/$$lang; fi;\
		for file in $$lang/*.txt; do \
			echo txt/$$file ">" tok/$$file 1>&2;\
			cat $$file \
			| perl -pe 's/^/ /g; s/\n/<br>/g; s/\s+/ /g; s/<br>/ \n /g; s/ +/ /g;' \
			| perl -pe 's/([!?,;:\)"\]-]+) / \1 /g; s/ ([\(\["]+)/ \1 /g; s/(\.) (["(\[]*]*)\s*([A-Z])/\1 \2 \3/g;' \
			| perl -pe 's/([?!.][")\]]*) /\1\n/g;' \
			| perl -pe 's/ +/ /g; s/^ //g; s/ +$$//g;' \
			> ../tok/$$file;\
		done;\
	done;\

#############
# alignment #
#############

tools/hunalign:
	@echo installing Hunalign, if you have a running instance, skip this step and create a symlink under tools/hunalign 1>&2
	@echo sources under https://github.com/danielvarga/hunalign 1>&2
	if [ ! -e tools/ ]; then mkdir tools; fi
	cd tools; \
	wget -nc ftp://ftp.mokk.bme.hu/Hunglish/src/hunalign/latest/hunalign-1.1.tgz; \
	tar zxvf hunalign-1.1.tgz;\
	cd hunalign-1.1/src/hunalign;\
	make;\
	ln -s hunalign-1.1/src/hunalign/hunalign .

dicts: tok tools/hunalign
	if [ ! -e dicts ]; then mkdir dicts; fi
	cd tok; \
	for lang in *; do \
		if [ $$lang != en ]; then \
			for file in $$lang/*.txt ; do \
				if [ -e en/`basename $$file` ]; then \
					echo prep $$file 1>&2; \
					cat en/`basename $$file` >> ../dicts/en4`basename $$lang`.txt;\
					cat $$file >> ../dicts/`basename $$lang`4en.txt;\
				fi;\
			done;\
			echo > ../dicts/$$lang.dic; \
			echo build dicts/$$lang.dic 1>&2; \
			#if timeout 10m --kill-after=11m \
			if timeout -k 11m 10m \
				../tools/hunalign ../dicts/$$lang.dic ../dicts/en4`basename $$lang`.txt ../dicts/`basename $$lang`4en.txt -utf -realign -autodict=../dicts/$$lang.dic >/dev/null; \
			then \
				echo "dicts/$$lang.dic:" `cat dicts/$$lang.dic | wc -l` entries 1>&2;\
			else \
				echo "dicts/$$lang.dic:" realign timeout 1>&2;\
			fi;\
			rm ../dicts/en4`basename $$lang`.txt ../dicts/`basename $$lang`4en.txt;\
		fi;\
	done;\

align: dicts tok tools/hunalign
	if [ ! -e align ]; then mkdir align; fi;
	cd tok; \
	for lang in *; do \
		if [ $$lang != en ]; then \
			if [ ! -e ../align/$$lang ] ; then mkdir ../align/$$lang ; fi; \
			if [ -e ../dicts/$$lang.dic ]; then \
				for file in $$lang/*.txt ; do \
					if [ -e en/`basename $$file` ]; then \
						echo align $$file 1>&2; \
						../tools/hunalign ../dicts/$$lang.dic en/`basename $$file` $$file -utf -realign -text -autodict=../dicts/$$lang.dic2 > ../align/$$file;\
						if [ -s ../dicts/$$lang.dic2 ]; then \
							cat ../dicts/$$lang.dic ../dicts/$$lang.dic2 | sort -u > ../dicts/$$lang.dic3;\
							mv ../dicts/$$lang.dic3 ../dicts/$$lang.dic;\
						fi;\
						if [ -e ../dicts/$$lang.dic2 ]; then rm ../dicts/$$lang.dic2; fi; \
					fi;\
				done;\
			fi;\
		fi; \
	done;

###############
# core corpus #
###############
# (a) 10.000 toks en, top 15 most translated files containing de,es,pt,it,fr
# (b) 125.000 toks en, top 100 most translated files containing de,es,pt,it,fr

# size checked with
# for file in `cat ../core_corpus.txt`; do cat en/$file; done | wc -w

core_corpus.txt: tok
	if [ ! -e core_corpus.txt ]; then \
		for file in tok/en/*; do \
			if [ -e tok/de/`basename $$file` ]; then \
			if [ -e tok/es/`basename $$file` ]; then \
			if [ -e tok/pt/`basename $$file` ]; then \
			if [ -e tok/it/`basename $$file` ]; then \
			if [ -e tok/fr/`basename $$file` ]; then \
				echo -n `basename $$file`' '; \
				echo tok/*/`basename $$file` \
				| wc -w; \
			fi; fi; fi; fi; fi;\
		done \
		| sed s/' '/'\t'/g \
		| sort -nr -k 2 \
		| tee core-corpus_full.txt \
		| cut -f 1 \
		| head -n 100 > core_corpus.txt;\
	fi;

core: core_corpus.txt
	for file in `cat core_corpus.txt | cut -f 1 -d '.' `; do \
		for dir in *; do \
			for lang in $$dir/*; do \
				lang=`basename $$lang`; \
				for src in $$dir/$$lang/$$file.*; do \
					if [ -e $$src ]; then \
						if [ ! -e core/$$lang/$$dir ]; then mkdir -p core/$$lang/$$dir; fi;\
						cp $$src core/$$lang/$$dir/;\
						echo $$src 1>&2;\
					fi;\
				done;\
			done;\
		done;\
	done;\


