#! /bin/sh

cd testtrack/
./update_full.sh i386 x86_64 ppc
./unpack_patterns.sh
cd ..
cd autobuild-lists/
./update_lists.sh
cd ..
./doit.sh || exit 0

echo "DVD"
diff autobuild-lists/dvd-all.list dvd-all.list | grep '^[<>]' | LC_ALL=C sort | grep -v 64bit 

echo "GNOME CD"
diff autobuild-lists/gnome-cd-all.list gnome-cd-all.list | grep '^[<>]' | LC_ALL=C sort | grep -v 64bit

echo "KDE CD"
diff autobuild-lists/kde-cd-all.list kde-cd-all.list | grep '^[<>]' | LC_ALL=C sort | grep -v 64bit

echo "Lang Addon CD"
diff autobuild-lists/langaddon-all.list langaddon-all.list | grep '^[<>]' | LC_ALL=C sort | grep -v 64bit

echo "NON-OSS Addon CD"
diff autobuild-lists/non_oss-all.list non_oss-all.list | grep '^[<>]' | LC_ALL=C sort | grep -v 64bit
