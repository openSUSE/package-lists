#!/bin/bash

arch=$*
if test -z "$arch"; then
  echo "usage: $0 <arch> <arch...>"
  exit
fi

for i in $arch;
do
  test -d full-$i || mkdir full-$i
  pushd full-$i > /dev/null
  test -d .cache || mkdir .cache
  find .cache -type f -mtime +10 | xargs -r rm 
  test -d suse || mkdir suse
  test -d media.1 || mkdir media.1
  echo "/ openSuSE-full-$i 11.1" > media.1/products
  rm susex
  ln -s /mounts/machcd3/dists/full-$i/suse susex
  echo > media.1/media <<EOF
SUSE Linux Products GmbH
20080513132816
1
EOF
  mkdir -p .cache
  echo -n "create_package_descr $i "
  /work/cd/bin/tools/create_package_descr -c .cache -i /work/cd/lib/put_built_to_cd/locations-stable/meta/ \
    -i /work/cd/lib/put_built_to_cd/locations-stable/debug/ \
    -P -C -K -S -x /work/built/dists/all/$i/data/EXTRA_PROV -o suse/setup/descr/ -d susex/ -l english > /dev/null 2>&1
  echo "done"
  popd > /dev/null
done
