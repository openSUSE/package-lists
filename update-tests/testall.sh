export LC_ALL=C

(cd ../osc/openSUSE\:Factory/_product/ && osc up )

for arch in i586 x86_64; do
  rm -rf /tmp/myrepos /var/cache/zypp
  export TESTTRACK=$PWD/../testtrack
  rm -rf $TESTTRACK/CD1
  mkdir -p $TESTTRACK/CD1
  cp -a $TESTTRACK/content.$arch.small $TESTTRACK/CD1/content
  cp -a $TESTTRACK/full-obs-$arch/suse $TESTTRACK/CD1/
  cp -a $TESTTRACK/full-obs-$arch/media.1 $TESTTRACK/CD1/

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
  rm -rf full-obs-$arch
  /usr/lib/zypp/testsuite/bin/deptestomatic.multi testit-$arch.xml > testit-$arch.log 2>&1
done

zcat full-obs-i586/*-package.xml.gz | fgrep -v '<vendor>' > full-obs-i586/1-package.xml
zcat full-obs-x86_64/*-package.xml.gz | fgrep -v '<vendor>' > full-obs-x86_64/1-package.xml

for i in *-update.xml; do 
  echo $i
  out=`./update.sh $i`
  if test -z "$out"; then
    echo "failed"
    grep -A7 Problem: $i.output
    grep "Can't find kind" $i.error
    continue
  fi

  cat $i.output | sed -n -e '1,/Other Valid Solution/p' | grep -v 'install product:' | grep '^>!>' | grep -e '^>!> \(install\|remove\|upgrade\|delete\) ' | sed -e 's,^>!> ,,; s, => .*,,; s,\[factor.*\].*,,; s,-[^-]*-[^-]*\.\(i.86\|noarch\|x86_64\)$,,' | sed -e "s,pattern:,," | cut -d' ' -f2 | sort -u > $i.list.new
  diff -u $i.list $i.list.new | grep '^[-]' | fgrep -v -- ---
done

