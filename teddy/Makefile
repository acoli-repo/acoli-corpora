SHELL=/usr/bin/bash

all: vtt

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