#!/bin/sh

do_opensuse()
{
    ./gen.sh opensuse/kde4_cd
    ./gen.sh opensuse/kde4_cd-default
    ./gen.sh opensuse/gnome_cd 
    ./gen.sh opensuse/gnome_cd-default 

    ./gen.sh opensuse/dvd-1
    ./gen.sh opensuse/dvd-2
    ./gen.sh opensuse/dvd-3
    ./gen.sh opensuse/dvd-base
    ./gen.sh opensuse/dvd9
    for i in i586 x86_64; do
      cat output/opensuse/dvd-1.$i.list output/opensuse/dvd-2.$i.list output/opensuse/dvd-3.$i.list output/opensuse/dvd-base.$i.list | LC_ALL=C sort -u > output/opensuse/dvd-$i.list
      cat output/opensuse/dvd-$i.list output/opensuse/dvd9.$i.list | LC_ALL=C sort -u > output/opensuse/dvd9-$i.list
    done

    ./gen.sh opensuse/kde4_cd-base-default
    ./gen.sh opensuse/kde4_cd-unstable
    ./gen.sh opensuse/gnome_cd-nobundles
    ./gen.sh opensuse/kde4_cd-nobundles
    ./gen.sh opensuse/gnome_cd-x11-default
    ./gen.sh opensuse/x11_cd
    ./gen.sh opensuse/x11_cd-initrd

    ./gen.sh opensuse/dvd-nonoss
    ./gen.sh opensuse/core_dvd x86_64 
    ./nonoss.sh

    echo "diffing"
    for arch in i586 x86_64; do
       diff -u output/opensuse/kde4_cd.$arch.list output/opensuse/kde4_cd-default.$arch.list | grep -v +++ | grep ^+
       diff -u output/opensuse/gnome_cd.$arch.list output/opensuse/gnome_cd-default.$arch.list | grep -v +++ | grep ^+
    done

    ./gen.sh opensuse/promo_dvd
    ./gen.sh opensuse/dvd-addon_lang
    ./langaddon.sh
    return 0
}

do_opensuse
exit $?
