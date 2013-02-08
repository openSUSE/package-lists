rm -rf /tmp/myrepos
: > drops.xml
: > uninstalls.xml
for i in `sed -e 's,.*>\(.*\)</ob.*,\1,' ../osc/openSUSE\:Factory/_product/obsoletepackages.inc`; do
   grep -xq $i $1.list || continue
   echo "<droporphaned kind=\"package\" name=\"$i\"/>" >> drops.xml
   echo "<uninstall kind=\"package\" name=\"$i\"/>" >> uninstalls.xml 
done

#DEPTESTOMATIC=/usr/bin/deptestomatic
DEPTESTOMATIC=/home/package-lists/bin/deptestomatic

sed -e '/!-- DROPS -->/r drops.xml' $1 > $1.tmp
$DEPTESTOMATIC $1.tmp 2> $1.error | tee $1.output | sed -n -e '1,/Other Valid Solution/p' | grep -v ' pattern:' | grep -v 'install product:' | grep '^>!>' | grep -e '^>!> \(install\|remove\|upgrade\) ' | sed -e 's,^>!> ,,; s, => .*,,; s,\[factor.*\].*,,; s,-[^-]*-[^-]*\.\(i.86\|noarch\)$,,'

sed -e '/!-- DROPS -->/r uninstalls.xml' $1 > $1.uninstalls
$DEPTESTOMATIC $1.uninstalls 2> $1.error2 > $1.output2 
list=`diff -u $1.output $1.output2 | grep "^+.*remove " | sed -e 's,.*remove  ,,; s,-[^-]*-[^-]*\.\(i.86\|noarch\|x86_64\)$,,'`
for i in $list; do 
  echo "<obsoletepackage>$i</obsoletepackage>" >> ../osc/openSUSE:Factory/_product/obsoletepackages.inc
  LC_ALL=C sort -o ../osc/openSUSE:Factory/_product/obsoletepackages.inc -u ../osc/openSUSE:Factory/_product/obsoletepackages.inc
done

#rm $1.tmp
#rm drops.xml
