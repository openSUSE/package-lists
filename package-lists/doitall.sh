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
./doit.sh || exit 1
cd autobuild-lists/
./update_lists.sh
cd ..

fi

./difflist.sh

cd update-tests
./testall.sh
cd ..

svn commit -m "auto commit"

diff=0
for arch in i586 x86_64 ppc; do
  for f in gnome_cd-default gnome_cd kde4_cd-default kde4_cd kde3_cd gnome_cd-x11-default kde4_cd-base-default; do
     if ! diff -u saved/$f.$arch.list $f.$arch.list ; then
        diff=1 
        break
     fi
     test "$diff" = 0 || break
  done
done

test "$diff" = 0 && exit 0

tar cjf /package_lists/filelists.tar.bz2 *.list
cp *.list saved

set -e

./check_yast.sh dvd-all.i586.list __i386__
./check_yast.sh dvd-all.x86_64.list __x86_64__
./check_yast.sh dvd-all.ppc.list __ppc__

