#!/bin/sh

set -e

svn up /home/pattern
pushd /home/pattern/products/patterns-openSUSE-data 
out=`git pull`
popd
if test "$out" = "Already up-to-date." -a -z "$FORCE"; then
  echo "unchanged"
  exit 1
else
  echo "$out"
fi

arg=openSUSE
if test -n "$1"; then
  arg=$1
fi

if test $arg = openSUSE -o $arg = all; then
rm -rf /tmp/pattern*

sh ../prepare_patterns.sh i586 i386 openSUSE
sh ../prepare_patterns.sh x86_64 x86_64 openSUSE
#sh ../prepare_patterns.sh ppc powerpc openSUSE

cp /tmp/patterns.*//CD1/suse/setup/descr/* patterns

fi

exit 0
