SHELL := /bin/bash

all: wp.tsv

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

WP-1574.xml:
	echo TODO 1>&2