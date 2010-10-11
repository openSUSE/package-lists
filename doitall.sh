#! /bin/sh

git pull

diffonly=$1
if test -z "$diffonly" || test -d "$diffonly"; then
   (cd osc/openSUSE\:Factory/_product/ && osc up)
   : > output/opensuse/frozen.xml
   for i in `grep "package name=" osc/openSUSE\:Factory/_product/FROZEN.group | cut -d\" -f2`; do
      echo "<lock package='$i'/>" >> output/opensuse/frozen.xml
   done
   cd testtrack/
   ./update_full.sh obs-i586 obs-x86_64 
   echo -n "updating patterns "
   if ./unpack_patterns.sh $diffonly > patterns.log 2>&1; then
     touch dirty
     echo "done"
   else
     echo "unchanged"
   fi 
   cd ..
   osc api '/build/openSUSE:Factory/_result?package=bash&repository=standard' > /tmp/state
   if grep -q 'dirty="true"' /tmp/state || grep -q 'state="building"' /tmp/state; then
     echo "standard still dirty"
     exit 0
   fi
   # now sync again
   cd testtrack
   WITHDESCR=1 ./update_full.sh obs-i586 obs-x86_64 || touch dirty
   cd ..
   test -f dirty && ./doit.sh
fi

cd update-tests
test -f dirty && ./testall.sh
cd ..

diff=0
for arch in i586 x86_64; do
  for f in gnome_cd-default gnome_cd kde4_cd-default kde4_cd gnome_cd-x11-default kde4_cd-base-default x11_cd; do
     if ! diff -u saved/$f.$arch.list output/opensuse/$f.$arch.list ; then
        diff=1 
        break
     fi
     test "$diff" = 0 || break
  done
done

if test -f dirty; then
   ./gen.sh opensuse/x11_cd-boottest x86_64

if test "$diff" = 1; then
   echo "no diff"
   tar cjf /package_lists/filelists.tar.bz2 output/opensuse/*_cd*.list
   cp output/opensuse/*.list saved
fi

set -e

if perl create-requires x86_64 ; then
  perl create-requires i586 || true
fi
 
(installcheck i586 testtrack/full-obs-i586/suse/setup/descr/packages; installcheck x86_64 testtrack/full-obs-x86_64/suse/setup/descr/packages)  | grep "nothing provides"  | sed -e 's,-[^-]*-[^-]*$,,' | sort -u > /tmp/missingdeps
fi
echo "INSTALLCHECK:"
cat /tmp/missingdeps
echo "<<<"

#./rebuildpacs.sh

./check_yast.sh output/opensuse/dvd-i586.list __i386__
./check_yast.sh output/opensuse/dvd-x86_64.list __x86_64__

if test -f dirty; then
(
./check_size.sh output/opensuse/dvd-i586.list i586
./check_size.sh output/opensuse/dvd-x86_64.list x86_64
) | tee sizes
fi

./mk_group.sh output/opensuse/dvd-i586.list DVD-i586 osc/openSUSE\:Factory/_product/DVD5-i586.group only_i586
./mk_group.sh output/opensuse/dvd-x86_64.list DVD-x86_64 osc/openSUSE\:Factory/_product/DVD5-x86_64.group only_x86_64

./mk_group.sh output/opensuse/dvd9-i586.list DVD9-i586 osc/openSUSE\:Factory/_product/DVD9-i586.group only_i586
./mk_group.sh output/opensuse/dvd9-x86_64.list DVD9-x86_64 osc/openSUSE\:Factory/_product/DVD9-x86_64.group only_x86_64

./mk_group.sh output/opensuse/promo_dvd.i586.list REST-DVD-promo-i386 osc/openSUSE\:Factory/_product/DVD5-promo-i386.group only_i586
./mk_group.sh output/opensuse/promo_dvd.x86_64.list REST-DVD-promo-x86_64 osc/openSUSE\:Factory/_product/DVD5-promo-x86_64.group only_x86_64
./mk_group.sh output/opensuse/langaddon-all.list REST-DVD osc/openSUSE\:Factory/_product/DVD5-lang.group
( cd osc/openSUSE\:Factory/_product/ && osc ci -m "auto update" )

./mk_group.sh output/opensuse/x11_cd.x86_64.list DVD osc/system:install:head/_product/DVD.group
(cd osc/system:install:head/_product/ && osc ci -m "auto update")

(cd osc/openSUSE:Factory:Live/package-lists-openSUSE; osc up -e; cp /package_lists/filelists.tar.bz2 .; osc ci -m "update from desdemona" .)
(cd osc/openSUSE:Factory:Live/kiwi-oem-x11-x86_64; osc up -e)
(sed -n -e '1,/ PACKAGES BEGIN/p' osc/openSUSE\:Factory\:Live/kiwi-oem-x11-x86_64/kiwi-oem-x11.kiwi ; cat output/opensuse/x11_cd-boottest.x86_64.list | while read pack; do echo '<package name="'$pack'"/>'; done; sed -n -e '/ PACKAGES END/,$p'  osc/openSUSE\:Factory\:Live/kiwi-oem-x11-x86_64/kiwi-oem-x11.kiwi)| xmllint --format - > t && mv t osc/openSUSE\:Factory\:Live/kiwi-oem-x11-x86_64/kiwi-oem-x11.kiwi
(cd osc/openSUSE:Factory:Live/kiwi-oem-x11-x86_64; osc diff ; osc ci -m "update")

git commit -m "auto commit" -a
echo "all done"
git push

rm -f dirty
