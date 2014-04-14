#!/bin/sh

. ./options

BASEDIR=`pwd`
TESTTRACK="`pwd`/testtrack"

export LC_ALL=C

echo -n "processing $1"

if test -f config.sh; then
  . config.sh
fi

file=$1

# multiple setups (dvd5, dvd5-2, etc.)
base=${file/-*/}
base=`basename $base`

GEN_ARCH=$2

ret=0

GEN_URL="$BASEDIR/testtrack/full-$tree-$GEN_ARCH"

  sed -e "s,GEN_ARCH,$i," -e "s,GEN_URL,dir://$TESTTRACK/CD1," $file.xml.in > output/$file.$GEN_ARCH.xml
  includes=`grep -- "-- INCLUDE" $file.xml.in | sed -e "s,.*INCLUDE *,,; s, .*,,"`
  for include in $includes; do 
        if test -f output/$include; then
           finclude=output/$include
        else
           finclude=`dirname $file`/$include
           if test -f output/$finclude; then
             finclude=output/$finclude
           fi
           if test ! -f $finclude; then
             echo "MISSING: $finclude"
             exit 1
           fi
        fi
        sed -i -e "/!-- INCLUDE $include -->/r $finclude" output/$file.$GEN_ARCH.xml 
  done
  fgrep -v "!$GEN_ARCH" output/$file.$GEN_ARCH.xml > $file.$GEN_ARCH.xml.new && mv $file.$GEN_ARCH.xml.new output/$file.$GEN_ARCH.xml

  /usr/lib/zypp/testsuite/bin/deptestomatic.multi output/$file.$GEN_ARCH.xml 2> output/$file.$GEN_ARCH.error > output/$file.$GEN_ARCH.output
  sed -n -e '1,/Other Valid Solution/p' output/$file.$GEN_ARCH.output | grep -v 'install pattern:' | grep -v 'install product:' | grep "> install.*\[tmp\]"  |\
      sed -e 's,>!> install \(.*\)-[^-]*-[^-]*$,\1,' > output/$file.$GEN_ARCH.list.new
  if test -s "output/$file.$GEN_ARCH.list.new"; then
     mv "output/$file.$GEN_ARCH.list.new" "output/$file.$GEN_ARCH.list"
   
     # now get the pattern packages too
     prep_patterns patterns-openSUSE-XX
     /usr/lib/zypp/testsuite/bin/deptestomatic.multi output/$file.$GEN_ARCH.xml > output/$file-XX.$GEN_ARCH.output 2> /dev/null
     sed -n -e '1,/Other Valid Solution/p' output/$file-XX.$GEN_ARCH.output | grep "> install patterns-openSUSE.*\[tmp\]"  |\
      sed -e 's,>!> install \(.*\)-[^-]*-[^-]*$,\1,' >> output/$file.$GEN_ARCH.list
     LC_ALL=C sort -u -o output/$file.$GEN_ARCH.list output/$file.$GEN_ARCH.list
  else
     rm "output/$file.$GEN_ARCH.list.new"
     grep -C5 Problem: output/$file.$GEN_ARCH.output
     fgrep "Unknown item" output/$file.$GEN_ARCH.error
     ret=1
     echo -n "!"
  fi

  #rm -rf $TESTTRACK/CD1

if test "$ret" = 1; then
  echo " failed"
else
  echo " done"
fi

rm -rf /tmp/myrepos
exit $ret

