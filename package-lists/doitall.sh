#! /bin/sh

svn up

diffonly=$1
if test -z "$diffonly" || test -d "$diffonly"; then
cd testtrack/
./update_full.sh i386 x86_64 ppc
./unpack_patterns.sh $diffonly
cd ..
./doit.sh || exit 0
cd autobuild-lists/
./update_lists.sh
cd ..

fi

tar cvjf /package_lists/filelists.tar.bz2 dvd5-addon_lang.*.*list kde-cd.*.list \
     gnome-cd.*.list dvd-all.*.list kde-cd-non_oss.*.list gnome-cd-non_oss.*.list 
./difflist.sh

cd update-tests
./testall.sh

svn commit -m "auto commit"
