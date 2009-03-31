#!/bin/sh

svn up /home/pattern
(cd /home/pattern/products/patterns-openSUSE-data && git pull)

arg=openSUSE
if test -n "$1"; then
  arg=$1
fi

if test $arg = openSUSE -o $arg = all; then
rm -rf /tmp/pattern*

sh ../prepare_patterns.sh i586 i386 openSUSE
sh ../prepare_patterns.sh x86_64 x86_64 openSUSE
sh ../prepare_patterns.sh ppc powerpc openSUSE

cp /tmp/patterns.*//CD1/suse/setup/descr/* patterns

fi

if test $arg = sled -o $arg = all; then
rm -rf /tmp/pattern*
sh ../prepare_patterns.sh i586 i386 sled
sh ../prepare_patterns.sh x86_64 x86_64 sled

cp /tmp/patterns.*//CD1/suse/setup/descr/* patterns
fi

if test $arg = sles -o $arg = all; then
rm -rf /tmp/pattern*
sh ../prepare_patterns.sh i586 i386 sles
sh ../prepare_patterns.sh x86_64 x86_64 sles
sh ../prepare_patterns.sh ppc powerpc sles
sh ../prepare_patterns.sh ppc64 powerpc sles
sh ../prepare_patterns.sh ia64 ia64 sles

cp /tmp/patterns.*//CD1/suse/setup/descr/* patterns
fi

if test $arg = sdk -o $arg = all; then
rm -rf /tmp/pattern*
sh ../prepare_patterns.sh i586 i386 sdk
sh ../prepare_patterns.sh x86_64 x86_64 sdk
sh ../prepare_patterns.sh ppc powerpc sdk
sh ../prepare_patterns.sh ppc64 powerpc sdk
sh ../prepare_patterns.sh ia64 ia64 sdk
sh ../prepare_patterns.sh s390x s390x sdk

cp /tmp/patterns.*//CD1/suse/setup/descr/* patterns
fi


