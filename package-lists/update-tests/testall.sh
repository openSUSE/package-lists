rm -rf /tmp/myrepos
rm -rf full-i386 full-x86_64
/usr/lib/zypp/testsuite/bin/deptestomatic.multi testit-x86_64.xml > testit-x86_64.log 2>&1
rm -rf /tmp/myrepos
/usr/lib/zypp/testsuite/bin/deptestomatic.multi testit-i386.xml > testit-i386.log 2>&1

zcat full-i386/*-package.xml.gz | fgrep -v '<vendor>' > full-i386/1-package.xml
zcat full-x86_64/*-package.xml.gz | fgrep -v '<vendor>' > full-x86_64/1-package.xml

for i in *.xml.in; do 
echo $i
./update.sh $i > $i.update
if test ! -s $i.update; then
  grep -C3 === $i.output
  : > $i.remove
  continue
fi

sed -e 's,delete_unmaintained="false",delete_unmaintained="true",' $i > ${i/update.xml.in/remove.xml}
./update.sh ${i/update.xml.in/remove.xml} > $i.remove
diff -u $i.update $i.remove | grep '^[-+]'
done
