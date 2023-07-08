# retrieve from a URL with the following shape:
# https://www.bible.com/bible/455/
# apparently, not all versions are linked with ISO 639 language codes, but they can be reached as a *work*
# as parameter, hand over a version number

for version in $*; do 
	tgtdir=html/mis;
	vdir=$tgtdir/`echo $version | sed s/'.*\/'//g;`; 
	if [ ! -e $vdir ]; then 
    	mkdir -p $vdir;
        wget https://www.bible.com/bible/$version -O $vdir/tmp.html; 
        wget https://www.bible.com/versions/$version -O $vdir/index.html;
        #if echo > $vdir/bib.tsv; then echo creating $vdir/bib.tsv 1>&2; else echo cannot write to $vdir/bib.tsv 1>&2; exit 1; fi; 
        while [ -e $vdir/tmp.html ]; do 
        	cat $vdir/tmp.html \
            	| perl -pe 's/\s+/ /g; s/(<span data-usfm="([A-Z0-9]+\.[0-9]+\.[0-9]+)")/\nb.\2\t\1/g; s/<\/div/\n<\/div/g;' \
            	| grep -P '\t<span' \
                | cat;
            chap=`cat $vdir/tmp.html \
            	| perl -pe 's/<a/\n<a/g;' \
                | grep '<a' \
                | grep href \
                | grep -i 'Next Chapter' \
                | sed s/'^[^>]*href'//g \
                | sed s/"'"/'"'/g \
                | cut -f 2 -d '"' \
                | grep '/bible/' -m 1`;
            rm $vdir/tmp.html;
            if echo $chap | egrep '[A-Z0-9]'; then 
            	if wget https://www.bible.com/$chap -O $vdir/tmp.html; then 
            		echo $chap 1>&2;
                else 
                	rm $vdir/tmp.html;
                fi;
            fi;
		done | tee $vdir/bib.tsv;
		if [ -e $vdir/tmp.html ]; then rm $vdir/tmp.html; fi; 
    fi;
done;