#! /bin/sh

git pull

. ./options

(cd osc/openSUSE\:Factory/_product/ && osc up)
cd testtrack/
./update_full.sh obs-x86_64
./update_full.sh $tree-i586 $tree-x86_64 nf-$tree-i586 nf-$tree-x86_64
echo -n "updating patterns "
if ./unpack_patterns.sh $diffonly > patterns.log 2>&1; then
   touch ../dirty
   echo "done"
else
   echo "unchanged"
fi 
cd ..
osc api "/build/openSUSE:$proj/_result?package=bash&repository=standard" > /tmp/state
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
WITHDESCR=1 ./update_full.sh $tree-i586 nf-$tree-i586 $tree-x86_64 nf-$tree-x86_64 || touch ../dirty
cd ..

installcheck i586 testtrack/full-$tree-i586/suse/setup/descr/packages > output/opensuse/missingdeps.tmp || true
installcheck x86_64 testtrack/full-$tree-x86_64/suse/setup/descr/packages >> output/opensuse/missingdeps.tmp || true
perl processdeps.pl openSUSE:$proj < output/opensuse/missingdeps.tmp > output/opensuse/missingdeps
grep "nothing provides" output/opensuse/missingdeps  | sort -u > /tmp/missingdeps
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
