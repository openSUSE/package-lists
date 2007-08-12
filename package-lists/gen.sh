#! /bin/sh

file=$1
for pack in `pdb query --filter status:internal` `pdb query --filter status:candidate`; do
  grep -x $pack overwrites && continue
  LOCK="$LOCK <lock package=\"$pack\"/>"
  case $pack in
    *-KMP)
	pack=${pack/-KMP/-}
        for suffix in default bigsmp xen xenpae; do
           LOCK="$LOCK <lock package=\"$pack$suffix\"/>"
        done
        ;;
  esac
done

sed -e "s,<!-- INTERNALS -->,$LOCK," $file.xml.in | xmllint --format - > $file.xml

echo "done"

/usr/lib/zypp/testsuite/bin/deptestomatic.multi $file.xml 2> $file.error | tee $file.output | sed -n -e '1,/Other Valid Solution/p' | grep -v 'install pattern:' | grep -v 'install product:' | grep "> install.*\[tmp\]"  | sed -e 's,>!> install \(.*\)-[^-]*-[^-]*$,\1,' | LC_ALL=C sort -u -o $file.list -

