#!/bin/bash

#
# Blame to: Alberto Planas <aplanas@suse.com>
#

export LC_ALL=C

. ../options


#
# Process a package format file, extracting the packages names
#
# $suffix -- suffix of the directory name (full-XXXX)
# $output -- filename where we will store the packages names
#
function get_pkgs_names {
  suffix=$1; output=$2
  grep "^=Pkg" ../testtrack/full-$suffix/suse/setup/descr/packages | cut -d' ' -f2 > $output
}


#
# Remove some lines from a file, creating a backup.
#
# $file  -- filename were we want to remove lines
# $lines -- lines to remove
#
function remove_lines {
  file=$1; lines=$2
  mkdir -p backup

  cp $file backup/`basename $file`-`date +%Y%m%d%H%M%S%N`

  tmp=`mktemp`
  for line in $lines; do
    sed "/>$line</d" $file > $tmp
    mv $tmp $file
  done
}


FILE="../osc/openSUSE:Factory/_product/obsoletepackages.inc"

# Generate the list of obsolete packages
OBSPKGS=`mktemp`
sed -n 's/.*>\(.*\)<.*/\1/p' $FILE > $OBSPKGS

# Generate the list of actual non-free packages
for arch in i586 x86_64; do
  CURPKGS=`mktemp`
  get_pkgs_names nf-$tree-$arch $CURPKGS

  # Get the insersection of both files
  collisions=`comm -12 <(sort $OBSPKGS) <(sort $CURPKGS)`
  if [ -n "$collisions" ]; then
    echo "Collisions found between obsoletepackages.inc and full-nf-$tree-$arch. Cleaning ..."
    echo "Please, check backup directory."
    remove_lines $FILE "$collisions" 
  fi
  rm $CURPKGS
done

# Generate the list of actual free packages
# This is a sanity check task. We do not expect any collision here !!!
for arch in i586 x86_64; do
  CURPKGS=`mktemp`
  get_pkgs_names $tree-$arch $CURPKGS

  # Get the insersection of both files
  collisions=`comm -12 <(sort $OBSPKGS) <(sort $CURPKGS)`
  if [ -n "$collisions" ]; then
    echo "Warning !!! Collisions found between obsoletepackages.inc and full-$tree-$arch."
    remove_lines $FILE "$collisions" 
  fi
done

