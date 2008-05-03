rm -rf /tmp/myrepos
/usr/lib/zypp/testsuite/bin/deptestomatic.multi $1 2> $1.error | tee $1.output | sed -n -e '1,/Other Valid Solution/p' | grep -v ' pattern:' | grep -v 'install product:' | grep '^>!>' | grep -e '^>!> \(install\|remove\|upgrade\) ' | sed -e 's,^>!> ,,; s, => .*,,; s,\[factor.*\].*,,; s,-[^-]*-[^-]*\.\(i.86\|noarch\)$,,'

