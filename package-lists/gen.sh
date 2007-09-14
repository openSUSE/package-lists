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


# no ppc cds
if (echo $file | grep "cd" > /dev/null); then
  GEN_ARCH=${GEN_ARCH/ppc/}
  base=$file
else
  # multiple dvd setups (dvd5, dvd5-2, etc.)
  base=${file/-*/}
fi

for pack in `pdb query --filter status:internal` `pdb query --filter status:candidate` `pdb query --filter status:frozen`; do
  grep -x $pack overwrites && continue
  LOCK="$LOCK <lock package=\"$pack\"/>"
  case $pack in
    *-KMP)
	pack=${pack/-KMP/-}
        for suffix in default bigsmp xen xenpae; do
           LOCK="$LOCK <lock package=\"$pack$suffix\"/>"
        done
        ;;
  esac
done

for i in $GEN_ARCH;
do
  arch=$i
  echo "processing $arch..."
  eval VAR="\$GEN_URL_${i}"
  sed -e "s,<!-- INTERNALS -->,$LOCK," -e "s,GEN_ARCH,$i," -e "s,GEN_URL,dir://$TESTTRACK/$base.$arch/CD1," $file.xml.in | grep -v "!$arch" | xmllint --format - > $file.$arch.xml

  rm -rf /tmp/myrepos/*
  mkdir -p $TESTTRACK/$base.$arch/CD1/
  cp -a $VAR/content $TESTTRACK/$base.$arch/CD1/
  cp -a $VAR/suse $TESTTRACK/$base.$arch/CD1/
  cp -a $VAR/media.1 $TESTTRACK/$base.$arch/CD1/
  
  pushd $TESTTRACK/$base.$arch/CD1/suse/setup/descr/ > /dev/null
  for i in *; 
    do echo -n "META SHA1 "; 
    sha1sum $i | awk '{ORS=""; print $1}'; 
    echo -n " "; basename $i; 
  done >> $TESTTRACK/$base.$arch/CD1/content
  popd > /dev/null
  rm $TESTTRACK/$base.$arch/CD1/content.asc
  gpg  --batch -a -b --sign $TESTTRACK/$base.$arch/CD1/content

  /usr/lib/zypp/testsuite/bin/deptestomatic.multi $file.$arch.xml 2> $file.$arch.error | tee $file.$arch.output | sed -n -e '1,/Other Valid Solution/p' | grep -v 'install pattern:' | grep -v 'install product:' | grep "> install.*\[tmp\]"  | sed -e 's,>!> install \(.*\)-[^-]*-[^-]*$,\1,' | LC_ALL=C sort -u -o $file.$arch.list -

  echo "done"
done

rm -rf /tmp/myrepos/*
echo "all done"
