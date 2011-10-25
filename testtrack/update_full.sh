#!/bin/bash

arch=$*
if test -z "$arch"; then
  echo "usage: $0 <arch> <arch...>"
  exit
fi
worked=0

nonftp=`grep 'package name=' ../osc/openSUSE\:Factory/_product/NON_FTP_PACKAGES.group | cut -d\" -f2 | grep -v openSUSE-release`
ignore=--delete-excluded
for i in $nonftp; do
   ignore="$ignore --exclude $i.rpm"
done

for i in $arch;
do
  test -d full-$i || mkdir full-$i
  pushd full-$i > /dev/null
  test -d .cache || mkdir .cache
  find .cache -type f -mtime +10 | xargs -r rm 
  test -d suse || mkdir suse
  test -d media.1 || mkdir media.1
  echo "/ openSuSE-full-$i 11.2" > media.1/products
  case $i in
  obs-*)
     rarch=${i/obs-/}
     mkdir -p susex/$rarch
     echo -n "syncing $i "
     count=`rsync -av $ignore --exclude *.meta --exclude *debuginfo* --exclude *debugsource* --exclude openSUSE-images* --exclude installation-images* --delete backend-opensuse.suse.de::opensuse-internal/build/openSUSE:Factory/standard/$rarch/:full/ susex/$rarch/ | grep .rpm | wc -l`
     echo -n "found $count packages "
     if test "$count" = 0; then
        echo "done"
     else
        touch dirty
        echo
     fi
     ;;
  121-*)
     rarch=${i/121-/}
     mkdir -p susex/$rarch
     echo -n "syncing $i "
     count=`rsync -av $ignore --exclude *.meta --exclude *debuginfo* --exclude *debugsource* --exclude openSUSE-images* --exclude installation-images* --delete backend-opensuse.suse.de::opensuse-internal/build/openSUSE:12.1/standard/$rarch/:full/ susex/$rarch/ | grep .rpm | wc -l`
     echo -n "found $count packages "
     if test "$count" = 0; then
        echo "done"
     else
        touch dirty
        echo
     fi
     ;;
  power-*)
     rarch=${i/power-/}
     mkdir -p susex/$rarch
     echo -n "syncing $i "
     count=`rsync -av $ignore --exclude *.meta --exclude *debuginfo* --exclude *debugsource* --exclude openSUSE-images* --exclude installation-images* --delete backend-opensuse.suse.de::opensuse-internal/build/openSUSE:Factory:PowerPC/standard/$rarch/:full/ susex/$rarch/ | grep .rpm | wc -l`
     echo -n "found $count packages "
     if test "$count" = 0; then
        echo "done"
     else
        touch dirty
        echo
     fi
     ;;
  esac
  echo > media.1/media <<EOF
SUSE Linux Products GmbH
20080513132816
1
EOF
  if test -n "$WITHDESCR" && test -f dirty; then
  mkdir -p .cache
  echo -n "create_package_descr $i "
  /usr/bin/create_package_descr -c .cache -P -C -K -S -o suse/setup/descr/ -d susex/ -l english > /dev/null 2>&1
    # -x /work/built/dists/all/$i/data/EXTRA_PROV

  echo "done"
  rm -f dirty
  worked=1
  fi
  popd > /dev/null
done

exit $worked

