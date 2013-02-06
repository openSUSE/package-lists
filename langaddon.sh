#!/bin/sh

for i in i586 x86_64; do
  diff output/opensuse/dvd-1.$i.list output/opensuse/dvd-addon_lang.$i.list | grep '^>'  > output/opensuse/langaddon.$i.list
  LC_ALL=C sort -u output/opensuse/langaddon.$i.list | cut -d" " -f2 > t && mv t output/opensuse/langaddon.$i.list
done
