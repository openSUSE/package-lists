#!/bin/sh

for arch in i586 x86_64 ppc; do
for i in kde_cd kde_cd_non_oss gnome_cd gnome_cd_non_oss dvd5;
do
  rm -rf $i.$arch/*
   mkdir -p $i.$arch/CD1
done
done
