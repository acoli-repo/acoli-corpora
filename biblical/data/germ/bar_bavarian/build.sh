#!/bin/bash
MYHOME=`dirname $0`
SCRIPTS=../../../tools/
SRC=https://bibeltext.com/bairisch/genesis/1.htm
DESC=https://bar.wikipedia.org/wiki/Sturmibibl
TGT=html/`basename $(dirname $SRC)`/`basename $SRC`

##############
# PROCESSING #
##############

  if [ -s $MYHOME/bibl.tsv ]; then
    echo found $MYHOME/bibl.tsv, keeping it 1>&2
    cat $MYHOME/bibl.tsv
  else

    #
    # retrieve
    ############
    if [ -e $MYHOME/html ]; then
        echo found $MYHOME/html, skipping 1>&2
    else
      while [ ! -e $TGT ]; do
          if [ ! -e $MYHOME/html/`basename $(dirname $SRC)` ]; then
              mkdir -p $MYHOME/html/`basename $(dirname $SRC)`
          fi;
          SRC=`echo $SRC | sed s/'\/[^\.\/][^\.\/]*\/\.\.\/'/'\/'/g;`
          echo $SRC ">" $TGT 1>&2
          wget -nc $SRC -O $TGT
          SRC=`dirname $SRC`/`xmllint --html --recover --format $TGT --xpath "//a[text()='►']/@href[1]" | \
            sed -e s/'.*='//g -e s/'"'//g -e s/"'"//g`
            TGT=$MYHOME/html/`basename $(dirname $SRC)`/`basename $SRC`
      done
    fi

    #
    # process
    ###########

    books=`ls -tr $MYHOME/html` # exploits crawling order ;)
    for book in $books; do
        bid=`echo $book | \
          perl -pe '
          s/genesis/b.GEN/;
          s/exodus/b.EXO/;
          s/leviticus/b.LEV/;
          s/numbers/b.NUM/;
          s/deuteronomy/b.DEU/;
          s/joshua/b.JOS/;
          s/judges/b.JDG/;
          s/ruth/b.RUT/;
          s/1_samuel/b.1SA/;
          s/2_samuel/b.2SA/;
          s/1_kings/b.1KI/;
          s/2_kings/b.2KI/;
          s/1_chronicles/b.1CH/;
          s/2_chronicles/b.2CH/;
          s/ezra/b.EZR/;
          s/nehemiah/b.NEH/;
          s/esther/b.EST/;
          s/job/b.JOB/;
          s/psalms/b.PSA/;
          s/proverbs/b.PRO/;
          s/ecclesiastes/b.ECC/;
          s/songs/b.SON/;
          s/isaiah/b.ISA/;
          s/jeremiah/b.JER/;
          s/lamentations/b.LAM/;
          s/ezekiel/b.EZE/;
          s/daniel/b.DAN/;
          s/hosea/b.HOS/;
          s/joel/b.JOE/;
          s/amos/b.AMO/;
          s/obadiah/b.OBA/;
          s/jonah/b.JON/;
          s/micah/b.MIC/;
          s/nahum/b.NAH/;
          s/habakkuk/b.HAB/;
          s/zephaniah/b.ZEP/;
          s/haggai/b.HAG/;
          s/zechariah/b.ZEC/;
          s/malachi/b.MAL/;
          s/matthew/b.MAT/;
          s/mark/b.MAR/;
          s/luke/b.LUK/;
          s/acts/b.ACT/;
          s/romans/b.ROM/;
          s/1_corinthians/b.1CO/;
          s/2_corinthians/b.2CO/;
          s/galatians/b.GAL/;
          s/ephesians/b.EPH/;
          s/philippians/b.PHI/;
          s/colossians/b.COL/;
          s/1_thessalonians/b.1TH/;
          s/2_thessalonians/b.2TH/;
          s/1_timothy/b.1TI/;
          s/2_timothy/b.2TI/;
          s/titus/b.TIT/;
          s/philemon/b.PHM/;
          s/hebrews/b.HEB/;
          s/james/b.JAM/;
          s/1_peter/b.1PE/;
          s/2_peter/b.2PE/;
          s/1_john/b.1JO/;
          s/2_john/b.2JO/;
          s/3_john/b.3JO/;
          s/john/b.JOH/;  # replace after 1JO !!!
          s/jude/b.JUD/;
          s/revelation/b.REV/;'
        `
        chid=1
        while [ -e $MYHOME/html/$book/$chid.htm ]; do
            chap=$MYHOME/html/$book/$chid.htm
            xmllint --html --recover --format $chap | \
            perl -pe 's/\s+/ /g; s/(<div class="chap")/\n\1/g;' | \
            grep '<div class="chap"' | \
            perl -pe '
              s/(<span class="reftext")/\n\1/g;
              s/(<span class="maintext")/\t\1/g;
              s/<[^>\n\t]*>//g;
              s/<[^>\n\t]*//;
              s/[^<\n\t]*>//;
              s/([^\n]+\t)/'$bid.$chid.'$1/g;
              s/[\s^\n]*\t[\s^\n]*/\t/g;

              s/ *   De Bibl auf Bairisch[^\n]*//g;

              s/&auml;/ä/g;
              s/&Auml;/Ä/g;
              s/&ouml;/ö/g;
              s/&Ouml;/Ö/g;
              s/&szlig;/ß/g;
              s/&uuml;/ü/g;
              s/&Uuml;/Ü/g;

              ' | egrep '\.[0-9]+\.[0-9]+'
              chid=`echo 1+ $chid | bc`
        done
    done | cut -f 1,2 > $MYHOME/bibl.tsv
  fi;

#
# META
########

if [ ! -e $MYHOME/bibl.tsv.meta ]; then

  # import functions
  source $SCRIPTS/get-meta.sh

  ( # write meta, CES/TEI and DC metadata
    echo fileDesc/titleStmt"<TAB>title<TAB>De Bibl auf Bairisch (Sturmibibl, 1998)"
    echo fileDesc/sourceDesc"<TAB>creator<TAB>"Sturmibund · Salzburg · Bairn · Pfingstn 1998 · Hell Sepp
    echo fileDesc/sourceDesc"<TAB>source<TAB>"http://www.sturmibund.org/
    echo fileDesc/sourceDesc"<TAB>source<TAB>"$SRC
    echo fileDesc/notesStmt"<TAB>description<TAB>"`wget -O - https://bar.wikipedia.org/wiki/Sturmibibl | perl -pe 's/\s+/ /g; s/(<(br|p)[\s>\/])/\n$1/g;' | xmllint --recover --html --xpath "//p[1]" - | html_to_desc `
    echo lang"<TAB>language<TAB>"bar
  ) 2>/dev/null | sed s/"<TAB>"/'\t'/g > $MYHOME/bibl.tsv.meta
fi;

#
# CES/XML
##########

python3 $SCRIPTS/tsv2ces.py $MYHOME/bibl.tsv $MYHOME/bibl.tsv.meta > $MYHOME/bibl.xml

tmp=$MYHOME/bibl.xml.tmp
if xmllint --format --recover $MYHOME/bibl.xml > $tmp 2>$tmp.log ; then
  mv $tmp $MYHOME/bibl.xml;
  rm $tmp.log
else
  cat $tmp.log 1>&2
  rm $tmp.log $tmp
  exit 1
fi
