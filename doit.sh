#!/bin/sh

. ./options

for arch in i586 x86_64; do

    perl create_solv.pl openSUSE:$proj standard $arch
    perl create_solv.pl openSUSE:$proj:NonFree standard $arch

    installcheck $arch trees/openSUSE:$proj:NonFree-standard-$arch.solv | grep "nothing provides" | \
	sed -e 's,^.*nothing provides ,job install provides ,; s, needed by.*,,' | sort -u > opensuse/dvd-nonoss-deps-$arch

    ./gen.pl opensuse/kde4_cd $arch
    ./gen.pl opensuse/kde4_cd-default $arch
    ./gen.pl opensuse/gnome_cd $arch
    ./gen.pl opensuse/gnome_cd-default $arch 

    ./gen.pl opensuse/dvd-1 $arch
    ./gen.pl opensuse/dvd-2 $arch
    ./gen.pl opensuse/dvd-3 $arch
    ./gen.pl opensuse/dvd-base $arch
    ./gen.pl opensuse/dvd9 $arch

    cat output/opensuse/dvd-1.$arch.list output/opensuse/dvd-2.$arch.list output/opensuse/dvd-3.$arch.list output/opensuse/dvd-base.$arch.list | LC_ALL=C sort -u > output/opensuse/dvd-$arch.list
    cat output/opensuse/dvd-$arch.list output/opensuse/dvd9.$arch.list | LC_ALL=C sort -u > output/opensuse/dvd9-$arch.list

    ./gen.pl opensuse/kde4_cd-base-default $arch
    ./gen.pl opensuse/kde4_cd-unstable $arch
    ./gen.pl opensuse/gnome_cd-nobundles $arch
    ./gen.pl opensuse/kde4_cd-nobundles $arch
    ./gen.pl opensuse/gnome_cd-x11-default $arch
    ./gen.pl opensuse/x11_cd $arch

    if echo $file | grep -q -- "-default"; then
	for i in kernel-default powersave suspend OpenOffice_org-icon-themes smartmontools gtk-lang gimp-lang vte-lang icewm-lite yast2-trans-en_US bundle-lang-common-en opensuse-manual_en bundle-lang-kde-en bundle-lang-gnome-en openSUSE-release openSUSE-release-ftp kernel-default-base kernel-default-extra smolt virtualbox-ose-kmp-default ndiswrapper-kmp-default preload-kmp-default tango-icon-theme oxygen-icon-theme mono-core marble-data gnome-packagekit Mesa libqt4-x11 gnome-icon-theme xorg-x11-fonts-core ghostscript gio-branding-upstream grub grub2 grub2-branding-openSUSE plymouth-branding-openSUSE kdebase4-workspace-branding-openSUSE kdebase4-workspace libQtWebKit4 opensuse-startup_en glibc-locale; do
            grep -vx $i output/$file.$GEN_ARCH.list > t && mv t output/$file.$GEN_ARCH.list
	done
	grep -v patterns-openSUSE output/$file.$GEN_ARCH.list > t && mv t output/$file.$GEN_ARCH.list
    fi

    ./gen.pl opensuse/dvd-nonoss $arch
    
    diff -u output/opensuse/kde4_cd.$arch.list output/opensuse/kde4_cd-default.$arch.list | grep -v +++ | grep ^+
    diff -u output/opensuse/gnome_cd.$arch.list output/opensuse/gnome_cd-default.$arch.list | grep -v +++ | grep ^+
    
    ./gen.pl opensuse/promo_dvd $arch
    ./gen.pl opensuse/dvd-addon_lang $arch
done

./nonoss.sh
./langaddon.sh

