rm -rf /tmp/myrepos
: > drops.list
for i in `grep obsoletepackage ../osc/openSUSE\:Factory/_product/obsoletepackages.inc | sed -e 's,.*>\(.*\)</ob.*,\1,'`; do
   grep -xq $i $1.list || continue
   echo "job droporphaned name $i" >> drops.list
done

sed -e '/# DROPS/r drops.list' $1 > $1.tmp

testsolv -r $1.tmp > $1.output
if grep -q ^problem $1.output; then
  testsolv $1.tmp >&2
  exit 1
fi

rm drops.list
