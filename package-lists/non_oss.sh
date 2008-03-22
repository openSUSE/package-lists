#!/bin/sh

for i in i586 x86_64;
do
  diff kde_cd.$i.list kde_cd_non_oss.$i.list  | grep "^>" | cut -d" " -f2
  diff gnome_cd.$i.list gnome_cd_non_oss.$i.list  | grep "^>" | cut -d" " -f2
done | LC_ALL=C sort -u > non_oss-all.list
