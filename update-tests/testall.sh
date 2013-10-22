export LC_ALL=C

. ../options
(cd ../osc/openSUSE\:Factory/_product/ && osc up )

#
# Process a single test case, recreating all the structures every time.
#
# $suffix -- the version that we need to test
# $arch   -- architecture that we are testing
# $output -- output suffix as indicated in the testit-*.xml files

function process {
  suffix=$1; arch=$2; output=$3

  rm -rf /tmp/myrepos /var/cache/zypp
  export TESTTRACK=$PWD/../testtrack
  rm -rf $TESTTRACK/CD1
  mkdir -p $TESTTRACK/CD1
  cp -a $TESTTRACK/content.$arch.small $TESTTRACK/CD1/content
  cp -a $TESTTRACK/full-$suffix/suse $TESTTRACK/CD1/
  cp -a $TESTTRACK/full-$suffix/media.1 $TESTTRACK/CD1/

  mkdir -p $TESTTRACK/CD1/suse/setup/descr/
  cp $TESTTRACK/patterns/dvd-*.$arch.pat $TESTTRACK/CD1/suse/setup/descr/
  pushd $TESTTRACK/CD1/suse/setup/descr/ > /dev/null
  : > patterns
  for i in *;
    do echo -n "META SHA1 ";
    sha1sum $i | awk '{ORS=""; print $1}';
    echo -n " "; basename $i;
    basename $i >> patterns
  done >> $TESTTRACK/CD1/content
  popd > /dev/null
  rm -f $TESTTRACK/CD1/content.asc
  gpg  --batch -a -b --sign $TESTTRACK/CD1/content
  rm -rf full-$output
  /usr/lib/zypp/testsuite/bin/deptestomatic.multi testit-$output.xml > testit-$output.log 2>&1

  zcat full-$output/*-package.xml.gz | fgrep -v '<vendor>' > full-$output/1-package.xml
}


for arch in i586 x86_64; do
  process $tree-$arch $arch $arch
  process nf-$tree-$arch $arch nf-$arch
done

for i in *-update.xml; do 
  echo $i
  out=`./update.sh $i`
  if test -z "$out"; then
    echo "failed"
    grep -A7 Problem $i.output
    grep "Can't find kind" $i.error
    continue
  fi

  sort -o $i.list -u $i.list
  cat $i.output | sed -n -e '1,/Other Valid Solution/p' | grep -v 'install product:' | grep '^>!>' | grep -e '^>!> \(install\|remove\|upgrade\|delete\) ' | sed -e 's,^>!> ,,; s, => .*,,; s,\[factor.*\].*,,; s,-[^-]*-[^-]*\.\(i.86\|noarch\|x86_64\)$,,; s,  *, ,g' | sed -e "s,pattern:,," | cut -d' ' -f2 | sort -u > $i.list.new
  diff=`diff -u $i.list $i.list.new | grep '^[-]' | fgrep -v -- --- | sed -e 's,^-,,'`
  for i in $diff; do
    grep -q ">$i<" ../osc/openSUSE\:Factory/_product/obsoletepackages.inc || echo "<obsoletepackage>$i</obsoletepackage>"
  done
done

