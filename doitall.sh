#! /bin/sh

git pull

(cd osc/openSUSE\:Factory/_product/ && osc up)
: > output/opensuse/frozen.xml
for i in `grep "package name=" osc/openSUSE\:Factory/_product/FROZEN.group | cut -d\" -f2`; do
   echo "<lock package='$i'/>" >> output/opensuse/frozen.xml
done
cd testtrack/
./update_full.sh obs-i586 obs-x86_64 
echo -n "updating patterns "
if ./unpack_patterns.sh $diffonly > patterns.log 2>&1; then
   touch ../dirty
   echo "done"
else
   echo "unchanged"
fi 
cd ..
osc api '/build/openSUSE:Factory/_result?package=bash&repository=standard' > /tmp/state
if grep -q 'dirty="true"' /tmp/state || grep -q 'state="building"' /tmp/state; then
   echo "standard still dirty"
   if ! test -f dirty; then
     ./rebuildppc.sh
   fi
   if test -z "$FORCE"; then
     exit 0
   fi
fi
# now sync again
cd testtrack
WITHDESCR=1 ./update_full.sh obs-i586 obs-x86_64 || touch ../dirty
cd ..

installcheck i586 testtrack/full-obs-i586/suse/setup/descr/packages > output/opensuse/missingdeps || true
installcheck x86_64 testtrack/full-obs-x86_64/suse/setup/descr/packages >> output/opensuse/missingdeps || true
grep "nothing provides" output/opensuse/missingdeps  | sed -e 's,-[^-]*-[^-]*$,,' | sort -u > /tmp/missingdeps
echo "INSTALLCHECK:"
cat output/opensuse/missingdeps
echo "<<<"

if test -f dirty; then
  if ! ./rebuildpacs.sh; then
     exit 0
  fi
  ./doit.sh
fi

cd update-tests
test -f ../dirty && ./testall.sh
cd ..

for f in output/opensuse/*.list; do
  saved=saved/`basename $f`
  if cmp -s $f $saved; then
    # reset timestamp
    cp -a $saved $f
  fi
done 

if test -f dirty; then
   ./gen.sh opensuse/x11_cd-boottest x86_64

   cp -a output/opensuse/*.list saved
fi

set -e

#if perl create-requires x86_64 ; then
#  perl create-requires i586 || true
#fi
 
./check_yast.sh output/opensuse/dvd-i586.list __i386__
./check_yast.sh output/opensuse/dvd-x86_64.list __x86_64__

(
./check_size.sh output/opensuse/dvd-i586.list i586
./check_size.sh output/opensuse/dvd-x86_64.list x86_64
) | tee sizes

./commit.sh

git commit -m "auto commit" -a
echo "all done"
git push || true

rm -fv dirty
#./rebuildppc.sh
