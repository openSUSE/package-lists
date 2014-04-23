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
./commit.sh

cd update-tests
./testall.sh
cd ..

set -e

git commit -m "auto commit" -a
echo "all done"
git push || true

