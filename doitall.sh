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

pushd create-drop-list
./createdrops.py trees/openSUSE:$proj-standard-x86_64.solv \
                 trees/openSUSE:NonFree:$proj-standard-x86_64.solv \
                 *.solv > osc/openSUSE:$proj/_product/obsoletepackages.inc
cd ../osc/openSUSE:$proj/_product
osc ci -m "updated drop list"
popd

cd update-tests
./testall.sh > update-tests-report.txt 2>&1
osc api -X PUT -f update-tests-report.txt /source/openSUSE:$proj:Staging/dashboard/update-tests.txt
cd ..

set -e

git commit -m "auto commit" -a
echo "all done"
git push || true

