#!/bin/bash
# retrieve bibles from http://m.bibles.org (582 languages/versions)
# build (roughly) Resnik-conformant CES/XML

SRC=src;			# directory to store the original downloads, should exist
TGT=xml;			# directory to store the resulting XML files, should exist
# NOTE: to be called from the directory where this file resides

if [ ! -e $SRC ]; then mkdir $SRC >& /dev/null; fi;
if [ ! -e $SRC ]; then echo download directory $SRC not found 1>&2;
else
	if [ ! -e $TGT ]; then mkdir $TGT >& /dev/null; fi;
	if [ ! -e $TGT ]; then echo target directory $TGT not found 1>&2;
	else 
		if [ ! -e $TGT/cesDoc.dtd ]; then cp cesDoc.dtd $TGT; fi;

		# retrieve language catalogue
		if [ ! -e $SRC/compare ]; then echo -n retrieve language catalogue ... 1>&2; wget -nc http://m.bibles.org/compare -O $SRC/compare; echo done 1>&2; fi

		# create versions.txt
		if [ ! -e $TGT/versions.txt ]; 
		then
			echo -n build $TGT/versions.txt ... 1>&2;
			(xmllint --html --recover --noblanks --encode ascii --xmlout $SRC/compare | 			# enforce valid XML in ascii
			tr '\n' ' ' | sed s/'<'/'\n<'/g | 														# normalize line breaks
			grep -A 999999999 '<div id="allVersions">' | grep '"version\[\]"' |						# identify language ids and names
			sed s/'.*value="\([^"]*\)\"[^>]*>\([^<]*\).*'/'\1\t\2'/ |								# retrieve language id and names
			sed -e s/'\([^(]*\)([^)]*) *'/'\1'/ | sort -u;											# trim and sort
			echo -n '#';
			date) > $TGT/versions.txt;
			echo done 1>&2;
		fi;
		
		# dump bibles
		for lang in `sed -e s/'[\t#].*'// $TGT/versions.txt`; do
			if [ ! -e $TGT/$lang.xml ]; then
				if [ -e $SRC/$lang.zip ]; then unzip -e $SRC/$lang.zip; fi
				if [ ! -e $SRC/$lang.xml ]; then 
					echo -n retrieve $SRC/$lang ... 1>&2;
					echo "lynx -accept_all_cookies -source http://m.bibles.org/$lang > $SRC/$lang.html" 1>&2;
					lynx -accept_all_cookies -source http://m.bibles.org/$lang > $SRC/$lang.html;
					echo "xmllint --html --format --recover --encode ascii --xmlout $SRC/$lang.html > $SRC/$lang.xml" 1>&2;
					xmllint --html --format --recover --encode ascii --xmlout $SRC/$lang.html > $SRC/$lang.xml; 
					rm $SRC/$lang.html;
					echo done 1>&2;
				fi;
				if [ -e $SRC/$lang.xml ]; then
					if [ ! -e $SRC/$lang ]; then mkdir $SRC/$lang; fi;
					BOOKS=`grep -A 999999999 -i '<UL CLASS="book">' $SRC/$lang.xml | egrep '/'$lang'/' | sed s/'.*\/'$lang'\/\([^\/#]*\).*'/'\1'/g | grep -v '<' | uniq`;

					##################
					# begin  header  #
					##################
					DATE=`date`;
					(echo '<?xml version="1.0" encoding="utf-8"?>
					<!DOCTYPE cesDoc SYSTEM "cesDoc.dtd">
<cesDoc version="4.3" type="bible" TEIform="modif-TEI.corpus 2">
  <cesHeader version="4.1" type="text" creator="'$0' by Christian Chiarcos" status="new" date.created="'$DATE'" TEIform="modif-TEI.corpus 2" lang="'`echo $lang | sed s/'-.*'//`'">
    <fileDesc>
      <titleStmt>
        <h.title>'`grep -m 1 $lang $TGT/versions.txt | sed s/'^[^\t]*\t'//`'</h.title>
        <respStmt>
          <respName>'$0' by Christian Chiarcos</respName>
          <respType>converted from tab format to CES-style XML</respType>
        </respStmt>
      </titleStmt>
      <editionStmt version="1.0">initial release</editionStmt>
      <publicationStmt>
        <distributor>Christian Chiarcos</distributor>
        <pubAddress>Goethe-University Frankfurt am Main, Germany</pubAddress>
        <availability status="restricted"><!-- to be clarified -->
		please see http://m.bibles.org/'$lang'
		
See below for copyright restrictions. If the original publication is confirmed to be available under an open or academic (non-commercial) license, it will also be redistributed as such (plus attribution).
If you are interested to use it, please contact Christian Chiarcos, christian.chiarcos@web.de</availability>
        <pubDate value="'$DATE'">'$DATE'</pubDate>
      </publicationStmt>
      <sourceDesc>
        <biblStruct>
          <monogr>
            <h.title>'`grep -m 1 $lang $TGT/versions.txt | sed s/'^[^\t]*\t'//`'</h.title>
            <imprint>
              <pubDate>Unknown</pubDate>
              <publisher/>
            </imprint>
          </monogr>
        </biblStruct>
      </sourceDesc>
    </fileDesc>
    <encodingDesc>
      <projectDesc>' | iconv -f utf-8 -t ascii -c;
		  xmllint --recover --format --encode ascii $SRC/$lang.xml | grep -A 99999 -m 1 '<div class="abs-copyright-legal">' | grep -B 99999 -m 1 '</div>' | \
		  sed -e s/'<[^>]*href="\([^\"]*\)\"[^>]*>'/'\nhttp:\/\/m.bibles.org\1\n'/g -e s/'<[^>]*>'/' '/g | egrep '[a-zA-Z]' | iconv -f utf-8 -t ascii -c;
		# xmllint $SRC/$lang.xml --xpath '//div[@class="abs-copyright-legal"]//text()|//div[@class="abs-copyright-legal"]//a/@href' | \
		# sed -e s/'HREF='/'href='/g -e s/'href="\([^\"]*\)\"'/'\nhttp:\/\/m.bibles.org\1\n'/g | egrep '[a-zA-Z]';
			## no --xpath in older xmllint versions
		w3m http://m.bibles.org/pages/terms-and-conditions | grep -A 999999999 -i -m 1 'TERMS AND CONDITIONS OF USE' | iconv -f utf-8 -t ascii -c;
echo '
This version is encoded in XML, conformant to the SGML specifications
of Philipp Resnik&apos;s parallel bibles (http://www.umiacs.umd.edu/~resnik/parallel/bible.html),
an adaption of the level 1 specifications of the
Corpus Encoding Standard, for non-commercial research use.
(XML conversion required minor adjustments of the DTD.)

NOTE: CES is superseded by the TEI, the encoding was chosen for compatibility with Resnik&apos;s bibles.</projectDesc>
      <editorialDecl>
        <conformance level="1">Corpus Encoding Standard, Version 2.0</conformance>
        <correction status="unknown" method="silent"/>
        <segmentation>Marked up to the level of chapter and verse.</segmentation>
      </editorialDecl>
    </encodingDesc>
    <profileDesc>
      <langUsage>
        <language id="'`echo $lang | sed s/'-.*'//`'" iso639="'`echo $lang | sed s/'-.*'//`'">'`echo $lang | sed s/'-.*'//`'</language>
      </langUsage>
      <wsdUsage>
        <writingSystem id="unknown">TO BE CHECKED !</writingSystem>
      </wsdUsage>
    </profileDesc>
  </cesHeader>
  <text>
    <body lang="'`echo $lang | sed s/'-.*'//`'" id="'$lang'">';
					##################
					# end  header  #
					################## 
					
					
					for book in $BOOKS; do
						if [ ! -e $SRC/$lang/$book ]; then mkdir $SRC/$lang/$book ; fi;
						CHAPTERS=`grep -A 999999999 -i '<UL CLASS="book">' $SRC/$lang.xml | egrep '/'$lang'/'$book'/' | sed s/'.*\/'$lang'\/'$book'\/\([^"]*\).*'/'\1'/g | grep -v '<'`;
						echo $book:$CHAPTERS 1>&2;
						for chapter in $CHAPTERS; do
							echo check $SRC/$lang/$book/$chapter 1>&2;
							if [ ! -e $SRC/$lang/$book/$chapter ]; then
								echo get $SRC/$lang/$book/$chapter ... 1>&2;
								# echo lynx -accept_all_cookies -source http://m.bibles.org/$lang/$book/$chapter > $SRC/$lang/$book/$chapter.html 1>&2;
								lynx -accept_all_cookies -source http://m.bibles.org/$lang/$book/$chapter | 	#> $SRC/$lang/$book/$chapter.html
								# echo xmllint --format --recover --encode ascii --xmlout --noblanks $SRC/$lang/$book/$chapter.html 1>&2;
								grep -v '<!' | #$SRC/$lang/$book/$chapter.html | 													# circumvent insufficient HTML5 (and charset) support -> UTF8 default
								xmllint --format --recover --encode ascii --xmlout --noblanks - | iconv -f ascii -t ascii -c > $SRC/$lang/$book/$chapter
								# rm $SRC/$lang/$book/$chapter.html;
								echo done 1>&2;
							fi;
						done;
						echo '<div type="book">';
						for chapter in $CHAPTERS; do \
							xsltproc chap2xml.xsl $SRC/$lang/$book/$chapter | xmllint --recover --encode ascii - | grep -v '<?';
						done;
						echo '</div>';
					done;
				echo '</body></text></cesDoc>') > $TGT/$lang.tmp;
				xmllint --recover $TGT/$lang.tmp | \
				xsltproc xml2ces.xsl - | xmllint --recover --encode utf-8 --format - | sed -e s/'>  *'/'>'/g -e s/'  *<\/seg>'/'<\/seg>'/g > $TGT/$lang.xml;
				fi;
				zip -rm $SRC/$lang.zip $SRC/$lang $SRC/$lang.xml $TGT/$lang.tmp
			fi;
		done
	fi;
fi;