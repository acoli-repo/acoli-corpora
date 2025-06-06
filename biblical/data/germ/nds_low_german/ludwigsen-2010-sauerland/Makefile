SHELL=bash

all: xml

xml: pdf
	@IFS=$$'\n';\
	if [ ! -e xml ]; then \
		mkdir xml;\
		for file in pdf/*pdf; do \
			tgt=xml/`basename $$file | sed s/'\s'/'_'/g`.xml;\
			echo $$file '>' $$tgt 1>&2;\
			pdftohtml -i -hidden -xml -stdout -fontfullname $$file \
			> $$tgt;\
			echo 1>&2;\
		done;\
	fi;

pdf:
	@if [ ! -e pdf ]; then \
		mkdir pdf; \
		cd pdf;\
		for url in http://sauerlandmundart.de/pdfs/daunlots%2014.pdf http://sauerlandmundart.de/pdfs/daunlots%2015.pdf http://sauerlandmundart.de/pdfs/daunlots%2016.pdf http://sauerlandmundart.de/pdfs/daunlots%2017.pdf http://sauerlandmundart.de/pdfs/daunlots%2018.pdf; do \
			echo $$url '>' pdf/`basename $$url` 1>&2;\
			wget $$url;\
			echo 1>&2;\
		done;\
	fi;
