export LC_ALL=C

rm -rf /tmp/myrepos
rm -rf full-head-i586 full-head-x86_64
/usr/lib/zypp/testsuite/bin/deptestomatic.multi testit-x86_64.xml > testit-x86_64.log 2>&1
rm -rf /tmp/myrepos
/usr/lib/zypp/testsuite/bin/deptestomatic.multi testit-i386.xml > testit-i386.log 2>&1

zcat full-head-i586/*-package.xml.gz | fgrep -v '<vendor>' > full-head-i586/1-package.xml
zcat full-head-x86_64/*-package.xml.gz | fgrep -v '<vendor>' > full-head-x86_64/1-package.xml

for i in *-update.xml; do 
  echo $i
  out=`./update.sh $i`
  if test -z "$out"; then
    grep -A7 Problem: $i.output
    continue
  fi

  cat $i.output | sed -n -e '1,/Other Valid Solution/p' | grep -v 'install product:' | grep '^>!>' | grep -e '^>!> \(install\|remove\|upgrade\|delete\) ' | sed -e 's,^>!> ,,; s, => .*,,; s,\[factor.*\].*,,; s,-[^-]*-[^-]*\.\(i.86\|noarch\|x86_64\)$,,' | sed -e "s,pattern:,," | cut -d' ' -f2 | sort -u > $i.list.new
  diff -u $i.list $i.list.new | grep '^[-]'
done

