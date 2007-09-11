#!/bin/sh

for i in i586 x86_64 ppc;
do
  cat dvd5.$i.list dvd5-2.$i.list | LANG=C sort -u > dvd-all.$i.list
done

LANG=C sort -u kde-cd.*.list  > kde-cd-all.list
LANG=C sort -u gnome-cd.*.list > gnome-cd-all.list

cat dvd-all.*.list | LANG=C sort -u > dvd-all.list
