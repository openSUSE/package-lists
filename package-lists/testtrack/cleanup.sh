#!/bin/sh

for i in kde-cd.i586 kde-cd-non_oss.i586 kde-cd-non_oss.x86_64 kde-cd.x86_64 gnome-cd.i586 gnome-cd-non_oss.i586 gnome-cd-non_oss.x86_64 gnome-cd.x86_64 dvd5.i586 dvd5.ppc dvd5.x86_64;
do
  rm -rf $i/*
  mkdir -p $i/CD1
done
