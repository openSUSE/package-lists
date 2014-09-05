rm -rf /tmp/myrepos
: > drops.list
: > uninstalls.list
for i in `sed -e 's,.*>\(.*\)</ob.*,\1,' ../osc/openSUSE\:Factory/_product/obsoletepackages.inc`; do
   grep -xq $i $1.list || continue
   echo "job droporphaned name $i" >> drops.list
   echo "job erase name $i" >> uninstalls.list
done

sed -e '/# DROPS/r drops.list' $1 > $1.tmp

testsolv -r $1.tmp > $1.output
# | sed -n -e '1,/Other Valid Solution/p' | grep -v ' pattern:' | grep -v 'install product:' | grep '^>!>' | grep -e '^>!> \(install\|remove\|upgrade\) ' | sed -e 's,^>!> ,,; s, => .*,,; s,\[factor.*\].*,,; s,-[^-]*-[^-]*\.\(i.86\|noarch\)$,,'
if grep -q ^problem $1.output; then
  testsolv $1.tmp >&2
  exit 1
fi

sed -e '/# DROPS/r uninstalls.list' $1 > $1.uninstalls
testsolv -r $1.uninstalls > $1.output2 

if grep -q ^problem $1.output2; then
  testsolv $1.uninstalls >&2
  exit 1
fi

diff -u $1.output $1.output2
exit 0

list=`diff -u $1.output $1.output2 | grep "^+.*remove " | sed -e 's,.*remove  ,,; s,-[^-]*-[^-]*\.\(i.86\|noarch\|x86_64\)$,,'`
for i in $list; do 
  echo "<obsoletepackage>$i</obsoletepackage>" >> ../osc/openSUSE:Factory/_product/obsoletepackages.inc
  LC_ALL=C sort -o ../osc/openSUSE:Factory/_product/obsoletepackages.inc -u ../osc/openSUSE:Factory/_product/obsoletepackages.inc
done

#rm $1.tmp
#rm drops.list uninstalls.list
