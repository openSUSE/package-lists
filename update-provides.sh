#! /bin/sh

export LC_ALL=C

for arch in i586 x86_64; do 
  mkdir -p provides/full-obs-$arch
  for i in testtrack/full-obs-$arch/susex/*/*.rpm; do
    pname=provides/full-obs-$arch/`basename $i`
    if test $i -nt $pname; then
      version=`rpm -qp --queryformat '%{VERSION}-%{RELEASE}' $i`
      name=`rpm -qp --queryformat '%{NAME}' $i`
      rpm -qp --provides $i | grep -v "^$name = $version" | grep -v "^$name(.*) = $version" | sort -u > $pname
    fi
  done
done

cd provides
list=`ls -1 * | sort -u`
for i in $list ; do cat */$i 2>/dev/null | sort -u | sed -e "s,^,$i:,"; done > current

