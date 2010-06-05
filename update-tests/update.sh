rm -rf /tmp/myrepos
: > drops.xml
for i in `sed -e 's,.*>\(.*\)</ob.*,\1,' ../osc/openSUSE\:Factory/_product/obsoletepackages.inc`; do
   grep -xq $i $1.list || continue
   echo "<uninstall kind=\"package\" name=\"$i\"/>" >> drops.xml
done

sed -e '/!-- DROPS -->/r drops.xml' $1 > $1.tmp
/usr/lib/zypp/testsuite/bin/deptestomatic.multi $1.tmp 2> $1.error | tee $1.output | sed -n -e '1,/Other Valid Solution/p' | grep -v ' pattern:' | grep -v 'install product:' | grep '^>!>' | grep -e '^>!> \(install\|remove\|upgrade\) ' | sed -e 's,^>!> ,,; s, => .*,,; s,\[factor.*\].*,,; s,-[^-]*-[^-]*\.\(i.86\|noarch\)$,,'
#rm $1.tmp
#rm drops.xml
