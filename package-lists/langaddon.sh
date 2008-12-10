#!/bin/sh

echo -n > output/opensuse/langaddon-all.list

for i in i586 x86_64 ppc; do
  diff output/opensuse/dvd-1.$i.list output/opensuse/dvd-addon_lang.$i.list | grep '^>' >> output/opensuse/langaddon-all.list
done
LC_ALL=C sort -u output/opensuse/langaddon-all.list | cut -d" " -f2 > t && mv t output/opensuse/langaddon-all.list
