SHELL=/usr/bin/bash

all: update_sources

youtube:
	@# works, but for selected videos, only
# 	youtube-dl -i --skip-download --console-title --all-subs --sub-format vtt https://www.youtube.com/watch?v=6zCpRVP1DgQ 
	youtube-dl -i --skip-download --console-title --all-subs --sub-format vtt  https://www.youtube.com/user/TEDxTalks

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
			if rmdir vtt/$$file 2>/dev/null; then echo ' empty' 1>&2; else echo ' '; ls vtt/$$file | perl -pe 's/\s/ /g; s/\.vtt//g;' 1>&2; echo 1>&2; fi;\
		fi;\
	done;
