#! /bin/sh

diffonly=$1
if test -z "$diffonly" || test -d "$diffonly"; then
cd testtrack/
./update_full.sh i386 x86_64 ppc
./unpack_patterns.sh $diffonly
cd ..
cd autobuild-lists/
./update_lists.sh
cd ..
./doit.sh || exit 0
fi

./difflist.sh
