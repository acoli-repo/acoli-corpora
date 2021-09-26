#!/bin/#!/usr/bin/env bash
# synchronize with and update with data from https://github.com/christos-c/bible-corpus/tree/master/bibles

MYHOME=`dirname $0`
if [ ! -e $MYHOME/data ]; then
  svn checkout https://github.com/christos-c/bible-corpus/trunk $MYHOME/data
else
  svn update $MYHOME/data
fi

for file in $MYHOME/data/bibles/*.xml; do
  iso=`egrep -m 1 ' iso639="' $file | \
       sed s/'\s'/'\n'/g | grep lang= | \
       sed s/'"'/'\n'/g | egrep -A 1 = | tail -n 1`
  if grep $file $MYHOME/mapping.tsv >&/dev/null; then
    tgt=$MYHOME/../../data/`grep -m 1 $file $MYHOME/mapping.tsv | sed s/'.*\s'//g`
    if [ -e $tgt ] ; then
      echo found $tgt, no updates 1>&2
    else
      mkdir -p $tgt
      cp $file $tgt
      cp $MYHOME/data/CHANGELOG  $MYHOME/data/LICENSE  $MYHOME/data/README.md $tgt
    fi
  else
    echo warning: please add $file $iso to $MYHOME/mapping.tsv for proper processing 1>&2
  fi
done;
