#!/bin/bash
export LC_ALL=C

proj=$1
(cd ../osc/openSUSE\:$proj/_product/ && osc up )

#
# Process a single test case, recreating all the structures every time.
#
# $suffix -- the version that we need to test
# $arch   -- architecture that we are testing
# $output -- output suffix as indicated in the testit-*.xml files

for i in $(ls -1 *-update.t | tac); do 
  echo "testing $i"
  ./update.sh $i $proj || break
done

