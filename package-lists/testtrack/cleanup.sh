#!/bin/sh

for arch in i586 x86_64 ppc; do
for i in kde_cd gnome_cd dvd5 promo_dvd;
do
  rm -rf $i.$arch/*
   mkdir -p $i.$arch/CD1
done
done
