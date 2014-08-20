#! /bin/sh

git pull

. ./options

(cd osc/openSUSE\:$proj/_product/ && osc up)
osc api "/build/openSUSE:$proj/_result?package=bash&repository=standard" > "$proj.state"
if grep -q 'dirty="true"' "$proj.state" || grep -q 'state="building"' "$proj.state"; then
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

