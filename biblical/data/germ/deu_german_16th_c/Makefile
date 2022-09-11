all: luther-1545.tsv luther-1545.tsv.meta
	@SRC=luther-1545.tsv; \
	TGT=`echo $$SRC | sed s/'\.tsv$$'//`.xml; \
	TMP=$$TGT.tmp;\
	echo $$SRC $$TGT $$TMP; \
        python3 ../../../tools/tsv2ces.py -l -m luther-1545.tsv $$SRC.meta > $$TGT;\
        if xmllint --format --recover $$TGT > $$TMP 2>$$TGT.log ; then \
          mv $$TMP $$TGT; \
          rm $$TGT.log;\
        else \
                cat $$TGT.log 1>&2; \
                rm $$TGT.log $$TMP;\
                exit 1; \
        fi;

luther-1545.tsv: www.zeno.org id2file.tsv
	@lastbook="_";\
	for id_file in `cat id2file.tsv | egrep '[a-zA-Z]' | sed s/'\t'/'<TAB>'/g`; do \
		id=`echo $$id_file | sed s/'<TAB>.*'//`;\
		file=`echo $$id_file | sed s/'.*<TAB>'//`;\
		book="_";\
		if echo $$id  | egrep '^[ab].[A-Z0-9]*\.[0-9].*$$' >/dev/null; then \
			book=`echo $$id | perl -pe "s/([A-Z][^\.]*)\..*/\1/g;"`; \
		fi;\
		if echo $$id | egrep '^\s*$$' >/dev/null; then \
			id=`echo $$file | sed -e s/'.*\/'//g -e s/'[^a-zA-Z0-9][^a-zA-Z0-9]*'/'_'/g;	`; \
		fi; \
		if [ -e $$file ]; then \
			echo $$file 1>&2; \
			echo '#' $$file; \
			xmllint --html --recover $$file --xpath "//h4/text()" | \
				head -n 1 | sed s/'^.*'/$$book'._._\t<h>&<\/h>'/g; \
			xmllint --html --recover $$file --xpath "//p[count(./ancestor::*[@class='holzingerAd'])=0]" | \
				perl -pe 's/&#13;/ /g; s/\[[^\]]*\]/ /g; s/\s+/ /g; s/<\/p>/<\/p>\n/g; s/(<p[ \/])/\n\1/g;' | \
				# pruning \
				perl -pe 's/<([\/])?(i|b|img)( [^>]*)?>//g;' | \
				perl -pe 's/<span[^>]*\/>//g;' | \
				grep -v 'class="empf"' | \
				# footnote refs \
				perl -pe 's/<a[^>]*href="([^"]*\/)?([^"\/]+#F[^"]+)"[^>]*><sup[^>]*>[^<]*<\/sup>/<fn href="\2"\/>/g;' | \
				# footnotes \
				perl -pe 's/<a[^>]href="([^"]*\/)?([^"\/]+)#N([^"]+)"[^>]*>[^<]*<\/a>\s*(.*)\s*$$/\n'$$id'._\t<fn name="\2#F\3">\4<\/fn>\n/g;' | \
				# drop markup \
				perl -pe 's/<([\/])?[pa]( [^>]*)?>//g; s/<sup/\n<sup/g;' | \
				# verse nr \
				perl -pe 's/<sup> *([0-9]+) *<\/sup>/'$$id'.\1\t/g;' | \
				# pruning \
				perl -pe 's/<([\/])?(sup)>//g;' | \
				# unnumbered text \
				perl -pe 's/^([^\t]*[a-zA-Z][^\t]*)$$/'$$id'._\t\1/g;' | \
				# <fn> => <a> \
				perl -pe 's/<fn/<a/g; s/<\/fn/<\/a/g;' | \
				# pruning \
				egrep '[a-zA-Z]'; \
			echo;\
		fi;\
	done > luther-1545.tsv

www.zeno.org:
	wget -r -np -F -nc -l inf -e robots=off --no-glob http://www.zeno.org/Literatur/M/Luther,+Martin/Luther-Bibel+1545/
	
