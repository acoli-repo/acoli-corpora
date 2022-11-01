SHELL := /bin/bash

all: wp

wp:
	mkdir wp
	cd wp;\
	for i in {0..9}; do \
		wget -nc "https://titus.fkidg1.uni-frankfurt.de/texte/etcs/balt/lit/wp/wp00$$i.htm"; \
	done;\
	for i in {10..75}; do \
		wget -nc "https://titus.fkidg1.uni-frankfurt.de/texte/etcs/balt/lit/wp/wp0$$i.htm"; \
	done;\
	