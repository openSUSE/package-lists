#! /bin/sh

git pull --rebase

proj=$1
repo=$2
test -n "$proj" || proj=Factory
test -n "$repo" || repo=standard

(cd osc/openSUSE\:$proj/_product/ && osc up)
osc api "/build/openSUSE:$proj/_result?package=bash&repository=$repo" > "$proj.state"
if grep -q 'dirty="true"' "$proj.state" || grep -q 'state="building"' "$proj.state"; then
   echo "$repo still dirty"
   if test -z "$FORCE"; then
     exit 0
   fi
fi
./doit.sh $proj
./commit.sh $proj

pushd create-drop-list
#susetags2solv -d MANUAL_OBSOLETES > MANUAL_OBSOLETES.solv
./createdrops.py ../trees/openSUSE:$proj-standard-x86_64.solv \
                 ../trees/openSUSE:$proj:NonFree-standard-x86_64.solv \
                 *.solv > ../osc/openSUSE:$proj/_product/obsoletepackages.inc
cd ../osc/openSUSE:$proj/_product
osc ci -m "updated drop list"
popd

cd update-tests
./testall.sh $proj > update-tests-report.txt 2>&1
osc api -X PUT -f update-tests-report.txt /source/openSUSE:$proj:Staging/dashboard/update-tests.txt
cd ..

set -e

git commit -m "auto commit" -a
echo "all done"
# git push < /dev/null || true

