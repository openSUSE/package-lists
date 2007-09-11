#!/bin/sh

for i in i586 x86_64 ppc;
do
  cat dvd5*.$i.list | LANG=C sort -u > dvd-all.$i.list

done
cat dvd-all.*.list | LANG=C sort -u > dvd-all.list
