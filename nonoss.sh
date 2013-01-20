#!/bin/sh

source ./options

export LC_ALL=C

for i in i586 x86_64; do
  diff output/opensuse/dvd-1.$i.list output/opensuse/dvd-nonoss.$i.list | grep '^>' > output/opensuse/nonoss.deps.$i.list
  : > output/opensuse/nonoss.$i.list
  find testtrack/full-nf-$tree-$i/susex/$i -name *.rpm | sort | while read file; do
    basename $file .rpm >> output/opensuse/nonoss.$i.list
  done
  sort -u output/opensuse/nonoss.deps.$i.list | cut -d" " -f2 > t && mv t output/opensuse/nonoss.deps.$i.list
done

diff output/opensuse/nonoss.deps.i586.list output/opensuse/nonoss.deps.x86_64.list | grep '^>' | cut -b2- > output/opensuse/nonoss.deps-x86_64.list
cat output/opensuse/nonoss.deps.i586.list output/opensuse/nonoss.deps.x86_64.list | sort | uniq -d > output/opensuse/nonoss.deps.list

diff output/opensuse/nonoss.i586.list output/opensuse/nonoss.x86_64.list | grep '^>' | cut -b2- > output/opensuse/nonoss-x86_64.list
cat output/opensuse/nonoss.i586.list output/opensuse/nonoss.x86_64.list | sort | uniq -d > output/opensuse/nonoss.list

