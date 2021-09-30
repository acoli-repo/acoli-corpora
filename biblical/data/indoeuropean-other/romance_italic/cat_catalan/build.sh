#!/bin/bash
# retrieve catalan bible and convert to simple TSV format

#
# prep
########
MYHOME=`dirname $0`
SCRIPTS=../../../../tools/
HTML=$MYHOME/html
HOST=https://web.archive.org/web/20080711105306/http://www.ibecat.org/

#
# retrieval
#############
if [ ! -e $HTML ]; then
  mkdir $HTML
  cd $HTML
  wget -nH -nc -r -np $HOST/biblia -O index.html
  wget -nH --cut-dirs=5 -nc -r -np $HOST/biblia/Coberta.htm

  # no idea why this doesn't work with the first call
  wget -nH --cut-dirs=5 -nc -r -np $HOST/biblia/Coberta.htm
  cd -
fi

#
# order of chaps
#################
# we exploit creation order

for testament in AT NT; do
  dir=$HTML/biblia/$testament;
  for book in `ls -tr $dir/`; do
    for chap in $dir/$book/*htm; do
      ch=`echo $chap | sed s/'.*[^0-9]\([0-9][0-9]*\)\.[html]*$'/'\1'/g`
      index=`echo 00$ch | sed s/'.*\(...\)$'/'\1'/;`
      id=`echo $book | perl -pe '
      s/Genesi/b.GEN/;
      s/Exode/b.EXO/;
      s/Levitic/b.LEV/;
      s/Nombres/b.NUM/;
      s/Deuteronomi/b.DEU/;
      s/Josue/b.JOS/;
      s/Jutges/b.JDG/;
      s/Rut/b.RUT/;
      s/1Samuel/b.1SA/;
      s/2Samuel/b.2SA/;
      s/1Reis/b.1KI/;
      s/2Reis/b.2KI/;
      s/1Croniques/b.1CH/;
      s/2Croniques/b.2CH/;
      s/Esdres/b.EZR/;
      s/Nehemies/b.NEH/;
      s/Ester/b.EST/;
      s/Job/b.JOB/;
      s/Salms/b.PSA/;
      s/Proverbis/b.PRO/;
      s/Eclesiastes/b.ECC/;
      s/Cantics/b.SON/;
      s/Isaies/b.ISA/;
      s/Jeremies/b.JER/;
      s/Lamentacions/b.LAM/;
      s/Ezequiel/b.EZE/;
      s/Daniel/b.DAN/;
      s/Osees/b.HOS/;
      s/Joel/b.JOE/;
      s/Amos/b.AMO/;
      s/Abdies/b.OBA/;
      s/Jonas/b.JON/;
      s/Miquees/b.MIC/;
      s/Nahum/b.NAH/;
      s/Habacuc/b.HAB/;
      s/Sofonies/b.ZEP/;
      s/Ageu/b.HAG/;
      s/Zacaries/b.ZEC/;
      s/Malaquies/b.MAL/;
      s/Mateu/b.MAT/;
      s/Marc/b.MAR/;
      s/Lluc/b.LUK/;
      s/Fets/b.ACT/;
      s/Romans/b.ROM/;
      s/1Corintis/b.1CO/;
      s/2Corintis/b.2CO/;
      s/Galates/b.GAL/;
      s/Efesis/b.EPH/;
      s/Filipencs/b.PHI/;
      s/Colossencs/b.COL/;
      s/1Tessalonicencs/b.1TH/;
      s/2Tessalonicencs/b.2TH/;
      s/1Timoteu/b.1TI/;
      s/2Timoteu/b.2TI/;
      s/Titus/b.TIT/;
      s/Filemo/b.PHM/;
      s/Hebreus/b.HEB/;
      s/Jaume/b.JAM/;
      s/1Pere/b.1PE/;
      s/2Pere/b.2PE/;
      s/1Joan/b.1JO/;
      s/2Joan/b.2JO/;
      s/3Joan/b.3JO/;
      s/Joan/b.JOH/;
      s/Judes/b.JUD/;
      s/Apocalipsi/b.REV/;
      '`
      # echo $chap $index'<TAB>'$id.$ch.XYZ'<TAB>'... | sed s/'<TAB>'/'\t'/g;
      # echo $chap
      # echo $chap $index'\t'$id.$ch

      cat $chap | \
      perl -pe '
        s/\&nbsp;/ /g;
        s/\s+/ /g;
        s/\s*(<(br|p)[^a-zA-Z0-9])/\n$1/g;
      ' | \
      perl -pe '
        s/^[\s^\n]+//g;
        s/<[^>\n]*>//g;
      ' | \
      #egrep -a '^\s*[0-9]' | \
      perl -pe 's/^\s*([0-9][0-9]*)\s/'$index'\t'$id.$ch.'$1\t/g;'
      #cat; echo | \
    done | \
    # sort -a -n | \
    cut -f 2-3 | egrep -a '^b\.' | \
    egrep -a '\t.*[a-zA-Z]' | \
    sed s/'\&quot;'/'"'/g | \
    sed s/'\s*window.addEvent.*'//g;
  done
done | \
iconv -f windows-1252 -t utf-8 > $MYHOME/cat.tsv

#
# META
#########
# retrieve meta data for XML conversion, in TSV format

if [ ! -e $MYHOME/cat.tsv.meta ]; then
  # import functions
  source $SCRIPTS/get-meta.sh

  ( # write meta, CES/TEI and DC metadata
    echo fileDesc/titleStmt"<TAB>title<TAB>Bblia Evanglica Catalana (BEC, 2000)"
    echo fileDesc/notesStmt"<TAB>description<TAB>"`get_internet_archive_timestamp_from_utf8 $HTML/index.html`
    echo fileDesc/sourceDesc"<TAB>creator<TAB>"`html_to_desc $HTML/biblia/credits.htm`
    echo fileDesc/sourceDesc"<TAB>source<TAB>"http://www.ibecat.org/
    echo fileDesc/sourceDesc"<TAB>description<TAB>"`html_to_desc $HTML/biblia/biblia2000.htm`
    echo lang"<TAB>language<TAB>"cat
  ) | sed s/"<TAB>"/'\t'/g > $MYHOME/cat.tsv.meta
fi;

#
# CES/XML export
##################

python3 $SCRIPTS/tsv2ces.py $MYHOME/cat.tsv $MYHOME/cat.tsv.meta > $MYHOME/cat.xml

tmp=$MYHOME/cat.xml.tmp
if xmllint --format --recover $MYHOME/cat.xml > $tmp 2>$tmp.log ; then
  mv $tmp $MYHOME/cat.xml;
  rm $tmp.log
else
  cat $tmp.log 1>&2
  rm $tmp.log $tmp
  exit 1
fi
