#!/bin/bash
proj="$1"
product="$2"

cd create-drop-list
./create-solv.sh $proj
git add $proj/*.solv
susetags2solv -d MANUAL_OBSOLETES > MANUAL_OBSOLETES.solv
./createdrops.py ../trees/openSUSE:$proj-standard-x86_64.solv \
                 ../trees/openSUSE:$proj:NonFree-standard-x86_64.solv \
		 $proj/*.solv \
                 *.solv > ../osc/openSUSE:$proj/$product/obsoletepackages.inc
cd ../osc/openSUSE:$proj/$product
osc ci -m "updated drop list"
