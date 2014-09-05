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
  echo $i
  out=`./update.sh $i`
  if test -z "$out"; then
    echo "failed"
    grep -A7 Problem $i.output
    grep "Can't find kind" $i.error
    continue
  fi

  if false; then
  sort -o $i.list -u $i.list
  cat $i.output | sed -n -e '1,/Other Valid Solution/p' | grep -v 'install product:' | grep '^>!>' | grep -e '^>!> \(install\|remove\|upgrade\|delete\) ' | sed -e 's,^>!> ,,; s, => .*,,; s,\[factor.*\].*,,; s,-[^-]*-[^-]*\.\(i.86\|noarch\|x86_64\)$,,; s,  *, ,g' | sed -e "s,pattern:,," | cut -d' ' -f2 | sort -u > $i.list.new
  diff=`diff -u $i.list $i.list.new | grep '^[-]' | fgrep -v -- --- | sed -e 's,^-,,'`
  for i in $diff; do
    grep -q ">$i<" ../osc/openSUSE\:Factory/_product/obsoletepackages.inc || echo "<obsoletepackage>$i</obsoletepackage>"
  done
fi
done

