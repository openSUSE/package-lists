export LC_ALL=C

. ../options
(cd ../osc/openSUSE\:Factory/_product/ && osc up )

#
# Process a single test case, recreating all the structures every time.
#
# $suffix -- the version that we need to test
# $arch   -- architecture that we are testing
# $output -- output suffix as indicated in the testit-*.xml files

for i in *-update.t; do 
  ./update.sh $i
done

