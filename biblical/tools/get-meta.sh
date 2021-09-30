#!/bin/bash
# functions to retrieve meta data from various source formats, in TSV format

# functions to return one line per request, taking either UTF-8 file(s) or streams as input
# for metadata extraction

get_internet_archive_timestamp_from_utf8() {
  # reads stream or file, assumes that it is UTF-8 and will silently ignore encoding errors

  cat $* | \
  iconv -f utf-8 -t utf-8 -c | \
  perl -pe 's/\s+/ /g; s/(<!--)/\n$1/g; s/(-->)/$1\n/g;' | \
  grep -A 1 '</html>' | \
  #cat; echo |\
  grep '<!-- ' | \
  sed -e s/'<!--'//g -e s/'-->'//g | \
  egrep -m 1 '[a-zA-Z]' | \
  perl -pe 's/^\s+//g; s/\s+/ /g; s/\s+$//g;';
  echo
}

html_to_desc() {
  cat $* | \
  #iconv -f utf-8 -t utf-8 -c | \
  w3m -T text/html | \
  perl -pe 's/\s*\n\s*/ \/ /g; s/\s+/ /g;' | \
  perl -pe 'while(m/\/ +\//) { s/\/ +\//\//g; }; s/^\s*\/\s*//; s/\s*\/\s*$//;'
  echo
}

## with proper encoding
# iconv -f windows-1252 -t utf-8 -c $SRC/index.html | \
# get_internet_archive_timestamp_from_utf8

## assume it's unicode
# get_internet_archive_timestamp_from_utf8 $SRC/index.html
