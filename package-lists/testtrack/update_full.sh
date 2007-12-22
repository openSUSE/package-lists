#!/bin/bash

arch=$*
if test -z "$arch"; then
  echo "usage: $0 <arch> <arch...>"
  exit
fi

for i in $arch;
do
  pushd full-$i > /dev/null
# ln -s /work/CDs/all/full-$i/suse susex
  mkdir -p .cache
  echo -n "create_package_descr $i "
  /work/cd/bin/tools/create_package_descr -c .cache -i /work/cd/lib/put_built_to_cd/locations-stable/meta/ \
    -i /work/cd/lib/put_built_to_cd/locations-stable/debug/ \
    -P -C -K -S -x /work/built/dists/all/$i/data/EXTRA_PROV -o suse/setup/descr/ -d susex/ -l english > /dev/null 2>&1
  echo "done"
  popd > /dev/null
done
