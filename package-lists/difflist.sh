#!/bin/sh

difflist()
{
   diff -u autobuild-lists/$1 $1 | grep '^+' | grep -v '^[-+][-+]' | LC_ALL=C sort | grep -v 64bit | cut -b2- > /package_lists/"$2"+
   diff -u autobuild-lists/$1 $1 | grep '^-' | grep -v '^[-+][-+]' | LC_ALL=C sort | grep -v 64bit | cut -b2- > /package_lists/"$2"-
}
         
difflist dvd-all.list suse111-dvd5-i386
difflist langaddon-all.list suse111-cd-lang-i386
difflist sled-all.list sled11-dvd-i386
#difflist promo_dvd.i586.list suse110-dvd5-promo-i386

diff -u autobuild-lists/sles-all.list sles-all.list > /package_lists/purely_for_kukuk

