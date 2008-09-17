#!/bin/bash
# usage:
# ./mk_group.sh dvd-all.list REST-DVD osc/openSUSE:Factory/group.REST-DVD.xml

list=$1
name=$2
dest=$3

pushd $PWD/`dirname $dest` > /dev/null
  osc up
popd > /dev/null


echo "<group name=\"$name\">" > $dest
echo "<packagelist id=\"$name\">" >> $dest

for i in `cat $list`;
do
  echo "<package name=\"$i\"/>" >> $dest
done

echo "</packagelist>" >> $dest
echo "</group>" >> $dest

pushd $PWD/`dirname $dest` > /dev/null
   osc addremove `basename $dest`
   osc ci -m "auto update" `basename $dest`
popd > /dev/null
