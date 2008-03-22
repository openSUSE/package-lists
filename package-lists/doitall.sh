#! /bin/sh

svn up

diffonly=$1
if test -z "$diffonly" || test -d "$diffonly"; then
cd testtrack/
./update_full.sh i386 x86_64 ppc
echo -n "updating patterns "
./unpack_patterns.sh $diffonly > patterns.log 2>&1
echo "done"
cd ..
./doit.sh || exit 0
cd autobuild-lists/
./update_lists.sh
cd ..

fi

tar cvjf /package_lists/filelists.tar.bz2 *.list 
./difflist.sh

cd update-tests
./testall.sh
cd ..

svn commit -m "auto commit"
