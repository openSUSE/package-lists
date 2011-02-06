#!/bin/bash
# usage:
# ./split_dvd9 list1 list2 dest1 dest2 dest3

list1=$1
list2=$2
dest1=$3
dest2=$4
dest3=$5

export LC_ALL=C 

cat $list1 $list2 | sort | uniq -d > $dest1

: > $dest2
: > $dest3

for i in `cat $list1 $list2 | sort | uniq -u`;
do
  if grep -q -x "$i" $list1; then
     echo $i >> $dest2
  else
     echo $i >> $dest3
  fi
done

