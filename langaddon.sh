#!/bin/sh

echo -n > output/langaddon-all.list

for i in i586 x86_64; do
  diff output/dvd-1.$i.list output/dvd-addon_lang.$i.list | grep '^>' >> output/langaddon-all.list
done
LC_ALL=C sort -u output/langaddon-all.list | cut -d" " -f2 > t && mv t output/langaddon-all.list
