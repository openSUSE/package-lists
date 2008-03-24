#!/bin/sh

difflist()
{
   diff -u autobuild-lists/$1 $1 | grep '^+' | grep -v '^[-+][-+]' | LC_ALL=C sort | grep -v 64bit | cut -b2- > /package_lists/"$2"+
   diff -u autobuild-lists/$1 $1 | grep '^-' | grep -v '^[-+][-+]' | LC_ALL=C sort | grep -v 64bit | cut -b2- > /package_lists/"$2"-
}
         
difflist dvd-all.list suse110-dvd5-i386
difflist gnome_cd.i586.list suse110-cd-gnome-i386
difflist kde_cd.i586.list suse110-cd-kde-i386
difflist kde_cd2.i586.list suse110-cd-kde-experimental-i386
difflist gnome_cd.x86_64.list suse110-cd-gnome-x86_64
difflist kde_cd.x86_64.list suse110-cd-kde-x86_64
difflist langaddon-all.list suse110-cd-lang-i386
difflist non_oss-all.list suse110-cd-pay-i386
#difflist dvd-promo.list "PROMO DVD"
