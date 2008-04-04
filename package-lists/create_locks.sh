#! /bin/sh

for pack in $1; do
  grep -x $pack overwrites && continue
  echo "<lock package=\"$pack\"/>"
  echo "<lock package=\"$pack-32bit\"/>"
  echo "<lock package=\"$pack-64bit\"/>"
  case $pack in
    *-KMP)
	pack=${pack/-KMP/-}
        for suffix in default bigsmp xen xenpae pae; do
           echo "<lock package=\"$pack$suffix\"/>"
        done
        ;;
  esac
done
