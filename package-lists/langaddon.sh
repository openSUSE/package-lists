#!/bin/sh

echo -n > langaddon-all.list

for i in i586 x86_64 ppc; do
  diff dvd5.$i.list dvd5-addon_lang.$i.list | grep '^>' >> langaddon-all.list
done
LANG=C sort -u langaddon-all.list | cut -d" " -f2 > langaddon-all.list.sorted && mv langaddon-all.list.sorted langaddon-all.list
