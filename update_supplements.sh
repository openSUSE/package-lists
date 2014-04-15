#! /bin/sh

grep Supplements: /work/SRC/all/*/*.spec | grep -v packageand | grep '('   | sed -e 's,.*Supplements: *,,' | tr ' ' '\012' | sed -e 's,([^:]*:\(.*\),(\1,' | \
   sort  -u | sed -e 's,^,namespace namespace:,; s,$, @SYSTEM,' > opensuse/all-supplements
