/usr/lib/zypp/testsuite/bin/deptestomatic.multi $1 2> 10.2-i386.error | tee 10.2-i386.output | sed -n -e '1,/Other Valid Solution/p' | grep -v ' pattern:' | grep -v 'install product:' | grep '^>!>' | grep -e '^>!> \(install\|remove\|upgrade\) ' | sed -e 's,^>!> ,,; s, => .*,,; s,\[factor.*\].*,,; s,-[^-]*-[^-]*\.\(i586\|noarch\)$,,'

