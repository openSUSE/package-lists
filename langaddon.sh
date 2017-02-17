#!/bin/sh

: ${proj:=Factory}

for i in i586 x86_64; do
  diff output/opensuse/$proj/dvd-1.$i.list output/opensuse/$proj/dvd-addon_lang.$i.list | grep '^>'  > output/opensuse/$proj/langaddon.$i.list
  LC_ALL=C sort -u output/opensuse/$proj/langaddon.$i.list | cut -d" " -f2 > output/opensuse/$proj/langaddon.$i.list.tmp && mv output/opensuse/$proj/langaddon.$i.list.tmp output/opensuse/$proj/langaddon.$i.list
done
