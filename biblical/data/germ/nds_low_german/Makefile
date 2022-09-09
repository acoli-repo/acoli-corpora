SHELL := /bin/bash

all: paulsen-1885.xml
	@if [ -e tmp ]; then rm -rf tmp; fi

tmp:
	@mkdir tmp

paulsen-1885.tsv: tmp
	@cd tmp; wget -nc https://www.gutenberg.org/files/64440/64440-h/64440-h.htm;

	@xmllint --html --recover --encode utf-8 --noent --xpath "//p" tmp/64440-h.htm | \
	perl -pe "s/&#13;/\r/g;" | \
	perl -pe 's/\s+/ /g; s/<\/p>/\n/g; s/[^\n]*(<p id="([^"]+)")/\2\t\1/g; s/<[^>]*\/>//g;' | \
	grep '<p id=' | \
	perl -pe 's/<a( [^>]*[^\/])?>[^<]*<\/a>//g;' | \
	perl -pe 's/<span( [^>]*[^\/])?>[^<]*<\/span>//g;' | \
	perl -pe 's/<[^>]*>//g;' |\
	perl -pe 's/ *[0-9]+\. */ /g;' |\
	perl -pe 's/^ *//g;' | \
	perl -pe 's/^Matth/b.MAT/;' | \
 	perl -pe 's/^Mark/b.MAR/;' | \
 	perl -pe 's/^Luk/b.LUK/;' | \
 	perl -pe 's/^Joh/b.JOH/;' | \
 	perl -pe 's/^Apost/b.ACT/;' | \
 	perl -pe 's/^Rom/b.ROM/;' | \
 	perl -pe 's/^ICor/b.1CO/;' | \
 	perl -pe 's/^IICor/b.2CO/;' | \
 	perl -pe 's/^Gal/b.GAL/;' | \
 	perl -pe 's/^Eph/b.EPH/;' | \
 	perl -pe 's/^Kol/b.COL/;' | \
 	perl -pe 's/^IThess/b.1TH/;' | \
 	perl -pe 's/^IIThess/b.2TH/;' | \
 	perl -pe 's/^ITim/b.1TI/;' | \
 	perl -pe 's/^IITim/b.2TI/;' | \
 	perl -pe 's/^Tit/b.TIT/;' | \
 	perl -pe 's/^Philem/b.PHM1/;' | \
 	perl -pe 's/^Phil/b.PHI/;' | \
 	perl -pe 's/^IPet/b.1PE/;' | \
 	perl -pe 's/^IIPet/b.2PE/;' | \
 	perl -pe 's/^IJoh/b.1JO/;' | \
 	perl -pe 's/^IIJoh/b.2JO1/;' | \
 	perl -pe 's/^IIIJoh/b.3JO1/;' | \
 	perl -pe 's/^Ebr/b.HEB/;' | \
 	perl -pe 's/^Jak/b.JAM/;' | \
 	perl -pe 's/^Jud/b.JUD1/;' | \
 	perl -pe 's/^Offenb/b.REV/;' | \
 	perl -pe 's/^Ps/b.PSA/;' | \
 	perl -pe 's/^(b\....)([0-9]+)\-([0-9]+\t)/\1.\2.\3/;' > paulsen-1885.tsv
	
paulsen-1885.xml: tmp paulsen-1885.tsv paulsen-1885.tsv.meta
	@TMP=tmp/paulsen-1885.xml;\
	TGT=paulsen-1885.xml;\
	python3 ../../../tools/tsv2ces.py paulsen-1885.tsv paulsen-1885.tsv.meta > $$TGT;\
	if xmllint --format --recover $$TGT > $$TMP 2>$$TGT.log ; then \
	  mv $$TMP $$TGT; \
	  rm $$TGT.log;\
	else \
  		cat $$TGT.log 1>&2; \
  		rm $$TGT.log $$tmp;\
  		exit 1; \
  	fi;
