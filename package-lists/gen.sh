#!/bin/sh

GEN_ARCH="i586 x86_64 ppc"
BASEDIR=`pwd`
GEN_URL_i586="$BASEDIR/testtrack/full-head-i586"
GEN_URL_x86_64="$BASEDIR/testtrack/full-head-x86_64"
GEN_URL_ppc="$BASEDIR/testtrack/full-head-ppc"
GEN_URL_ppc64="$BASEDIR/testtrack/full-head-ppc64"
GEN_URL_ia64="$BASEDIR/testtrack/full-head-ia64"
GEN_URL_s390x="$BASEDIR/testtrack/full-head-s390x"
TESTTRACK="`pwd`/testtrack"

echo -n "processing $1"

if test -f config.sh; then
  . config.sh
fi

file=$1
if test -n "$2"; then
  GEN_ARCH=$2
fi

# multiple setups (dvd5, dvd5-2, etc.)
base=${file/-*/}

if (echo $file | grep "promo" > /dev/null); then
  GEN_ARCH="i586"
  base=${file/-*/}
fi

if (echo $file | grep "sled" > /dev/null); then
  GEN_ARCH="i586 x86_64"
  base=${file/-*/}
fi

if (echo $file | grep "sles" > /dev/null); then
  GEN_ARCH="i586 x86_64 ppc64 ia64"
  base=${file/-*/}
fi

if (echo $file | grep "sdk" > /dev/null); then
  GEN_ARCH="i586 x86_64 ppc64 ia64 s390x"
  base=${file/-*/}
fi


LOCK=
LOCK2=
ignore_list=ignore_all

if (echo $file | grep "_cd" > /dev/null); then
   GEN_ARCH="i586 x86_64 ppc"
   export ignore_list="$ignore_list ignore_cds"
fi

if (echo $file | egrep "kde._cd" > /dev/null); then
   GEN_ARCH="i586 x86_64"
   export ignore_list="$ignore_list ignore_kde_cd"
fi

if (echo $file | grep "gnome_cd" > /dev/null); then
   GEN_ARCH="i586 x86_64"
   export ignore_list="$ignore_list ignore_gnome_cd"
fi

if (echo $file | grep "x11_cd" > /dev/null); then
   GEN_ARCH="i586 x86_64"
fi

internals=`pdb query --filter status:internal`
test -n "$internals" || exit 1

sh ./create_locks.sh $internals `pdb query --filter status:candidate` `pdb query --filter status:frozen` \
  `cat $ignore_list` > locks.xml
sh ./create_locks.sh $internals `pdb query --filter status:production,ProdOnly:sles_only` `pdb query --filter status:frozen` \
  `cat $ignore_list` `cd /work/cd/lib/put_built_to_cd/locations-stable/pay && ls -1 ` > sles-locks.xml

ret=0

for i in $GEN_ARCH;
do
  arch=$i
  echo -n " $arch"
  eval VAR="\$GEN_URL_${i}"
  sed -e '/!-- INTERNALS -->/r locks.xml' -e "s,GEN_ARCH,$i," -e "s,GEN_URL,dir://$TESTTRACK/$base.$arch/CD1," $file.xml.in > $file.$arch.xml
  sed -i -e '/!-- SLES_LOCKS -->/r sles-locks.xml' $file.$arch.xml
  includes=`grep -- "-- INCLUDE" $file.xml.in | sed -e "s,.*INCLUDE *,,; s, .*,,"`
  for include in $includes; do 
     sed -i -e "/!-- INCLUDE $include -->/r $include" $file.$arch.xml 
  done
  fgrep -v "!$arch" $file.$arch.xml > $file.$arch.xml.new && mv $file.$arch.xml.new $file.$arch.xml

  rm -rf /tmp/myrepos /var/cache/zypp
  mkdir -p $TESTTRACK/$base.$arch/CD1/
  cp -a $TESTTRACK/content.$arch.small $TESTTRACK/$base.$arch/CD1/content
  cp -a $VAR/suse $TESTTRACK/$base.$arch/CD1/
  cp -a $VAR/media.1 $TESTTRACK/$base.$arch/CD1/
  
  pushd $TESTTRACK/$base.$arch/CD1/suse/setup/descr/ > /dev/null
  : > patterns
  for i in *; 
    do echo -n "META SHA1 "; 
    sha1sum $i | awk '{ORS=""; print $1}'; 
    echo -n " "; basename $i; 
    basename $i >> patterns
  done >> $TESTTRACK/$base.$arch/CD1/content
  popd > /dev/null
  rm -f $TESTTRACK/$base.$arch/CD1/content.asc
  gpg  --batch -a -b --sign $TESTTRACK/$base.$arch/CD1/content

  export ZYPP_MODALIAS_SYSFS=/tmp
  /usr/lib/zypp/testsuite/bin/deptestomatic.multi $file.$arch.xml 2> $file.$arch.error | tee $file.$arch.output | sed -n -e '1,/Other Valid Solution/p' | grep -v 'install pattern:' | grep -v 'install product:' | grep "> install.*\[tmp\]"  | sed -e 's,>!> install \(.*\)-[^-]*-[^-]*$,\1,' | LC_ALL=C sort -u -o $file.$arch.list.new -
  if test -s "$file.$arch.list.new"; then
     mv "$file.$arch.list.new" "$file.$arch.list"
  else
     grep -C5 Problem: $file.$arch.output
     fgrep "Unknown item" $file.$arch.error
     ret=1
     echo -n "!"
  fi

done

if test "$ret" = 1; then
  echo " failed"
else
  echo " done"
  rm -f $file.all.list
  cat $file.*.list | LC_ALL=C sort -u > $file.all.list
fi

rm -rf /tmp/myrepos
exit $ret

