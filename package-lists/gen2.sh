#!/bin/sh

GEN_ARCH="i586 x86_64 ppc"
GEN_URL_i586="dir:///mounts/machcd2/dists/full-i386"
RO_URL_i586="/mounts/machcd2/dists/full-i386"
GEN_URL_x86_64="dir:///mounts/machcd2/dists/full-x86_64"
RO_URL_x86_64="/mounts/machcd2/dists/full-x86_64"
GEN_URL_ppc="dir:///mounts/machcd2/dists/full-ppc"
RO_URL_ppc="/mounts/machcd2/dists/full-ppc"

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

for i in ${GEN_ARCH};
do
  arch=$i
  echo "processing $arch..."
  eval VAR="\$GEN_URL_${i}"
  eval VAR2="\$RO_URL_${i}"
  sed -e "s,<!-- INTERNALS -->,$LOCK," -e "s,GEN_ARCH,$i," -e "s,GEN_URL,$VAR," $file.xml.in | grep -v "!$arch" | xmllint --format - > $file.$arch.xml

  mkdir -p /tmp/rw
  rm -rf /tmp/rw/*
  rm -rf /tmp/myrepos/*

  cp -a $VAR2/suse/setup/descr/* /tmp/rw/
  rm -f /tmp/rw/*.pat
  cp /home/kiwi/$base.$arch/CD1/suse/setup/descr/*.pat /tmp/rw/
  cp /home/kiwi/content.$arch.small /tmp/rw/content
  mount -o bind /tmp/rw/ $VAR2/suse/setup/descr/

  pushd $VAR2/suse/setup/descr/ > /dev/null
  for i in *; 
    do echo -n "META SHA1 "; 
    sha1sum $i | awk '{ORS=""; print $1}'; 
    echo -n " "; basename $i; 
  done >> /tmp/rw/content
  popd > /dev/null
  gpg  --batch -a -b --sign /tmp/rw/content
  mount -o bind /tmp/rw/content $VAR2/content
  mount -o bind /tmp/rw/content.asc $VAR2/content.asc 

  if test -f /home/kiwi/packages.$arch.gz; then
    mount -o bind /home/kiwi/packages.$arch.gz $VAR2/suse/setup/descr/packages.gz
  fi
  
  /usr/lib/zypp/testsuite/bin/deptestomatic.multi $file.$arch.xml 2> $file.$arch.error | tee $file.$arch.output | sed -n -e '1,/Other Valid Solution/p' | grep -v 'install pattern:' | grep -v 'install product:' | grep "> install.*\[tmp\]"  | sed -e 's,>!> install \(.*\)-[^-]*-[^-]*$,\1,' | LC_ALL=C sort -u -o $file.$arch.list -

  umount $VAR2/content
  umount $VAR2/content.asc
  if test -f /home/kiwi/packages.$arch.gz; then
    umount $VAR2/suse/setup/descr/packages.gz
  fi
  umount $VAR2/suse/setup/descr

  sleep 1

  echo "done"
done

rm -rf /tmp/rw/*
rm -rf /tmp/myrepos/*
echo "done"
