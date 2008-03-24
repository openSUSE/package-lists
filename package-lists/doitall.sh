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
for arch in i586 x86_64 ppc;
  for f in gnome_cd-default gnome_cd kde_cd-default kde_cd; do
     cmp -s saved/$f.$arch.list $f.$arch.list || diff=1 
  done
done

test "$diff" = 0 && exit 0

tar cvjf /package_lists/filelists.tar.bz2 *.list
cp *.list saved

