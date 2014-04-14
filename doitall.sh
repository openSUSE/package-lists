#! /bin/sh

git pull

. ./options

(cd osc/openSUSE\:Factory/_product/ && osc up)
osc api "/build/openSUSE:$proj/_result?package=bash&repository=standard" > /tmp/state
if grep -q 'dirty="true"' /tmp/state || grep -q 'state="building"' /tmp/state; then
   echo "standard still dirty"
   if test -z "$FORCE"; then
     exit 0
   fi
fi
./doit.sh

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

set -e

./commit.sh

git commit -m "auto commit" -a
echo "all done"
git push || true

rm -fv dirty
