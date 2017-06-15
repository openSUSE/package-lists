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
./create-drop-list.sh $proj

cd update-tests
./testall.sh $proj > update-tests-report.$proj.txt 2>&1

file="update-tests-report.$proj.txt"
remote="/source/openSUSE:$proj:Staging/dashboard/update-tests.txt"
if [ "$(< "$file")" != "$(osc api "$remote")" ] ; then
  osc -d api -X PUT -f "$file" "$remote"
fi

cd ..

set -e

git commit -m "auto commit for $proj/$repo" -a
echo "all done"
# git push < /dev/null || true

exit 0
