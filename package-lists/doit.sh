#!/bin/sh

do_sled()
{
    ./gen.sh sled-1 || return 1
    ./gen.sh sled-2 || return 1
    for i in i586 x86_64 all; do
      cat output/sled-1.$i.list output/sled-2.$i.list | LC_ALL=C sort -u > output/sled-$i.list
    done
    return 0
}

do_opensuse()
{
    ./gen.sh opensuse/kde4_cd
    ./gen.sh opensuse/kde4_cd-default
    ./gen.sh opensuse/kde3_cd
    ./gen.sh opensuse/gnome_cd 
    ./gen.sh opensuse/gnome_cd-default 

    ./gen.sh opensuse/dvd-1
    ./gen.sh opensuse/dvd-2
    ./gen.sh opensuse/dvd-3
    for i in i586 x86_64 ppc; do
      cat output/opensuse/dvd-1.$i.list output/opensuse/dvd-2.$i.list output/opensuse/dvd-3.$i.list | LC_ALL=C sort -u > output/opensuse/dvd-$i.list
    done
    ./gen.sh opensuse/kde4_cd-base-default
    ./gen.sh opensuse/gnome_cd-x11-default
    ./gen.sh opensuse/x11_cd
    ./gen.sh opensuse/x11_cd-initrd

    echo "diffing"
    for arch in i586 x86_64; do
       diff -u output/opensuse/kde4_cd.$arch.list output/opensuse/kde4_cd-default.$arch.list | grep -v +++ | grep ^+
       diff -u output/opensuse/gnome_cd.$arch.list output/opensuse/gnome_cd-default.$arch.list | grep -v +++ | grep ^+
    done


    for arch in i586 x86_64; do
      for i in kernel-default powersave suspend OpenOffice_org-icon-themes smartmontools gtk-lang gimp-lang vte-lang icewm-lite yast2-trans-en_US bundle-lang-common-en opensuse-manual_en bundle-lang-kde-en bundle-lang-gnome-en openSUSE-release openSUSE-release-ftp kernel-default-base kernel-default-extra smolt; do
	for f in gnome_cd-default kde4_cd-default gnome_cd-x11-default kde4_cd-base-default; do
	  grep -vx $i output/opensuse/$f.$arch.list > t && mv t output/opensuse/$f.$arch.list
	done
      done
      grep -vx openSUSE-release-ftp output/opensuse/x11_cd-initrd.$arch.list > t && mv t output/opensuse/x11_cd-initrd.$arch.list
    done

    ./gen.sh opensuse/promo_dvd
    ./gen.sh opensuse/dvd-addon_lang
    ./langaddon.sh
    return 0
}

do_sles()
{
    ./gen.sh sles-1 || return 1
    ./gen.sh sles-2 || return 1
    cat sles-*.all.list | LC_ALL=C sort -u > sles-all.list

    return 0
}

do_sdk()
{
    ./sdk-prepare.sh
    ./gen.sh sdk || return 1
    ./gen.sh sdk-2 || return 1
    ./sdk.sh
    return 0
}

do_sled 
RET=$?
do_opensuse
RET=$[ $? || $RET ]
#do_sles
#RET=$[ $? || $RET ]
#do_sdk
ET=$[ $? || $RET ]
exit $RET
