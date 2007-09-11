#!/bin/sh

echo -n > langaddon.list

for i in i586 x86_64 ppc; do
  diff dvd5.$i.list dvd5-addon_lang.$i.list | grep '^>' >> langaddon.list
done
LANG=C sort -u langaddon.list | cut -d" " -f2 > langaddon.list.sorted && mv langaddon.list.sorted langaddon.list
