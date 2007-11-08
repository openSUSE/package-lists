#! /bin/sh

diffonly=$1
if test -z "$diffonly" || test -d "$diffonly"; then
cd testtrack/
./update_full.sh i386 x86_64 ppc
./unpack_patterns.sh $diffonly
cd ..
cd autobuild-lists/
./update_lists.sh
cd ..
./doit.sh || exit 0
fi

difflist()
{
   echo "$2"
   diff -u autobuild-lists/$1 $1 | grep '^[+-]' | grep -v '^[-+][-+]' | LC_ALL=C sort | grep -v 64bit
   echo ""
}

#difflist dvd-all.list "DVD"
difflist gnome-cd-all.list "GNOME CD"
difflist kde-cd-all.list "KDE CD"
#difflist langaddon-all.list "Lang Addon CD"
#difflist non_oss-all.list "NON-OSS Addon CD"
#difflist dvd-promo.list "PROMO DVD"
