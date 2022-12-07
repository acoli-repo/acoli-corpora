SHELL := /bin/bash

all: WP-1574.xml 
	@# allow this to fail
	-make BP-1591.xml

wp:
	mkdir wp
	cd wp;\
	for i in {0..9}; do \
		wget -nc "https://titus.fkidg1.uni-frankfurt.de/texte/etcs/balt/lit/wp/wp00$$i.htm"; \
	done;\
	for i in {10..75}; do \
		wget -nc "https://titus.fkidg1.uni-frankfurt.de/texte/etcs/balt/lit/wp/wp0$$i.htm"; \
	done;\

wp.tsv: wp 
	@# we use ../../../germ/en_modern-english/douay_rheims_utf8.xml to get the proper order of books
	python3 titus2tsv.py wp/* -b ../../../germ/en_modern-english/douay_rheims_utf8.xml > wp.tsv

WP-1574.xml: wp.tsv wp.tsv.meta
	python3 ../../../../tools/tsv2ces.py wp.tsv wp.tsv.meta -x source_ref type file > WP-1574.xml

bp.tsv:
	wget -nc "https://raw.githubusercontent.com/acoli-repo/passage-finder/main/samples/bp.tsv?token=GHSAT0AAAAAABY6KNR5ZATYJHYIQZFIJR4WY4QKYQQ" -O bp.tsv

BP-1591.xml: bp.tsv
	@# will fail without bp.tsv
	python3 ../../../../tools/tsv2ces.py bp.tsv bp.tsv.meta -x source_ref type > BP-1591.xml