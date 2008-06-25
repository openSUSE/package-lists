#!/bin/sh

for i in i586 x86_64 ppc;
do
  cat dvd5.$i.list dvd5-2.$i.list dvd5-3.$i.list | LC_ALL=C sort -u > dvd-all.$i.list
  cat sled-1.$i.list | LC_ALL=C sort -u > sled-all.$i.list
done

cat sled-all.*.list | LC_ALL=C sort -u > sled-all.list
cat dvd-all.*.list | LC_ALL=C sort -u > dvd-all.list

