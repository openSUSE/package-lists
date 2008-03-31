#!/bin/sh

GEN_ARCH="i586 x86_64 ppc"
BASEDIR=`pwd`
GEN_URL_i586="$BASEDIR/testtrack/full-i386"
GEN_URL_x86_64="$BASEDIR/testtrack/full-x86_64"
GEN_URL_ppc="$BASEDIR/testtrack/full-ppc"
TESTTRACK="`pwd`/testtrack"

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

LOCK=
LOCK2=
ignore_list=ignore_all

if (echo $file | grep "_cd" > /dev/null); then
   ignore_list="$ignore_list ignore_cds"
fi

internals=`pdb query --filter status:internal`
test -n "$internals" || exit 1

for pack in $internals `pdb query --filter status:candidate` `pdb query --filter status:frozen` `pdb query --filter distributable:no` `cat $ignore_list` \
  `for i in /work/cd/lib/put_built_to_cd/locations-stable/sles_only/*; do basename $i; done`; do
  grep -x $pack overwrites && continue
  LOCK="$LOCK <lock package=\"$pack\"/>"
  LOCK2="$LOCK2 <lock package=\"$pack-32bit\"/>"
  LOCK2="$LOCK2 <lock package=\"$pack-64bit\"/>"
  case $pack in
    *-KMP)
	pack=${pack/-KMP/-}
        for suffix in default bigsmp xen xenpae pae; do
           LOCK="$LOCK <lock package=\"$pack$suffix\"/>"
        done
        ;;
  esac
done

ret=0

for i in $GEN_ARCH;
do
  arch=$i
  echo "processing $arch..."
  eval VAR="\$GEN_URL_${i}"
  sed -e "s,<!-- INTERNALS -->,<!-- INTERNALS -->$LOCK," -e "s,GEN_ARCH,$i," -e "s,GEN_URL,dir://$TESTTRACK/$base.$arch/CD1," $file.xml.in | sed -e "s,<!-- INTERNALS -->,<!-- INTERNALS -->$LOCK2," | fgrep -v "!$arch" | xmllint --format - > $file.$arch.xml

  rm -rf /tmp/myrepos
  mkdir -p $TESTTRACK/$base.$arch/CD1/
  cp -a $TESTTRACK/content.$arch.small $TESTTRACK/$base.$arch/CD1/content
  cp -a $VAR/suse $TESTTRACK/$base.$arch/CD1/
  cp -a $VAR/media.1 $TESTTRACK/$base.$arch/CD1/
  
  pushd $TESTTRACK/$base.$arch/CD1/suse/setup/descr/ > /dev/null
  for i in *; 
    do echo -n "META SHA1 "; 
    sha1sum $i | awk '{ORS=""; print $1}'; 
    echo -n " "; basename $i; 
  done >> $TESTTRACK/$base.$arch/CD1/content
  popd > /dev/null
  rm -f $TESTTRACK/$base.$arch/CD1/content.asc
  gpg  --batch -a -b --sign $TESTTRACK/$base.$arch/CD1/content

  export ZYPP_MODALIAS_SYSFS=/tmp
  /usr/lib/zypp/testsuite/bin/deptestomatic.multi $file.$arch.xml 2> $file.$arch.error | tee $file.$arch.output | sed -n -e '1,/Other Valid Solution/p' | grep -v 'install pattern:' | grep -v 'install product:' | grep "> install.*\[tmp\]"  | sed -e 's,>!> install \(.*\)-[^-]*-[^-]*$,\1,' | LC_ALL=C sort -u -o $file.$arch.list.new -
  if test -s "$file.$arch.list.new"; then
     mv "$file.$arch.list.new" "$file.$arch.list"
  else
     grep -C5 === $file.$arch.output
     ret=1
  fi

  echo "done"
done

rm -rf /tmp/myrepos
echo "all done: $ret"
exit $ret
