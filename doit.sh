#!/bin/bash

set -e
. ./options
export LC_ALL=C

if [ -n "$1" ]; then
	export proj="$1"
fi

echo "generate dvds for $proj at "
date

if [ ! -e osc/openSUSE\:$proj/_product/.osc ]; then
	mkdir -p osc
	cd osc
	osc co openSUSE:$proj _product
	cd -
fi

if [ ! -e osc-plugin-factory/bs_mirrorfull ]; then
	echo "please check out osc-plugin-factory here!" >&2
	exit 1
fi

grep -v openSUSE-release osc/openSUSE:$proj/_product/NON_FTP_PACKAGES.group | grep 'package name=' | \
   sed -e 's,.*package name=",job lock name ,; s,"/>,,' > opensuse/$proj/non_ftp_packages

for arch in i586 x86_64; do

    perl create_solv.pl openSUSE:$proj standard $arch
    perl create_solv.pl openSUSE:$proj:NonFree standard $arch

    ./dump_supplements \
	    trees/openSUSE:$proj-standard-$arch.solv \
	    trees/openSUSE:$proj:NonFree-standard-$arch.solv \
	    > opensuse/$proj/all-supplements

   # installcheck $arch trees/openSUSE:$proj:NonFree-standard-$arch.solv | grep "nothing provides" | \
#	sed -e 's,^.*nothing provides ,job install provides ,; s, needed by.*,,' | sort -u > opensuse/$proj/dvd-nonoss-deps-$arch

    ./gen.pl opensuse/$proj/kde4_cd $arch "$proj"
    ./gen.pl opensuse/$proj/kde4_cd-default $arch "$proj"
    ./gen.pl opensuse/$proj/gnome_cd $arch "$proj"
    ./gen.pl opensuse/$proj/gnome_cd-default $arch "$proj"

    # first flash
    : > opensuse/$proj/dvd-1.$arch.suggests
    if ./gen.pl opensuse/$proj/dvd-1 $arch "$proj"; then
    
      # then readd
      mv output/opensuse/$proj/dvd-1.$arch.suggests opensuse/$proj/dvd-1.$arch.suggests
      ./gen.pl opensuse/$proj/dvd-1 $arch "$proj"
    fi

    ./gen.pl opensuse/$proj/dvd-2 $arch "$proj"
    ./gen.pl opensuse/$proj/dvd-3 $arch "$proj"
    ./gen.pl opensuse/$proj/dvd-base $arch "$proj"
    ./gen.pl opensuse/$proj/dvd9 $arch "$proj"

    cat output/opensuse/$proj/dvd-1.$arch.list output/opensuse/$proj/dvd-2.$arch.list output/opensuse/$proj/dvd-3.$arch.list output/opensuse/$proj/dvd-base.$arch.list | LC_ALL=C sort -u > output/opensuse/$proj/dvd-$arch.list
    cat output/opensuse/$proj/dvd-$arch.list output/opensuse/$proj/dvd9.$arch.list | LC_ALL=C sort -u > output/opensuse/$proj/dvd9-$arch.list

    ./gen.pl opensuse/$proj/kde4_cd-base-default $arch "$proj"
    ./gen.pl opensuse/$proj/kde4_cd-unstable $arch "$proj"
    ./gen.pl opensuse/$proj/gnome_cd-nobundles $arch "$proj"
    ./gen.pl opensuse/$proj/kde4_cd-nobundles $arch "$proj"
    ./gen.pl opensuse/$proj/gnome_cd-x11-default $arch "$proj"
    ./gen.pl opensuse/$proj/x11_cd $arch "$proj"

    dumpsolv trees/openSUSE:$proj:NonFree-standard-$arch.solv | grep solvable:name: | sed -e 's,.*: ,,' | sort > output/opensuse/$proj/nonoss.$arch.list
    echo "repo nonfree-standard-$arch 0 solv trees/openSUSE:$proj:NonFree-standard-$arch.solv" >  opensuse/$proj/dvd-nonoss
    echo '#INCLUDE dvd-1' >>  opensuse/$proj/dvd-nonoss
    for pkg in $(grep -v openSUSE output/opensuse/$proj/nonoss.$arch.list); do 
      echo "job install name $pkg" >> opensuse/$proj/dvd-nonoss
    done
    if ./gen.pl opensuse/$proj/dvd-nonoss $arch "$proj"; then
      ( diff output/opensuse/$proj/dvd-1.$arch.list output/opensuse/$proj/dvd-nonoss.$arch.list | grep '^>' | cut '-d ' -f2 ;
        cat output/opensuse/$proj/nonoss.$arch.list ) | sort | uniq -u  > output/opensuse/$proj/nonoss.deps.$arch.list
    fi

    for file in output/opensuse/$proj/*default.$arch.list; do
	for i in kernel-default libyui-gtk-pkg6 libyui-gtk6 powersave suspend OpenOffice_org-icon-themes smartmontools gtk-lang gimp-lang vte-lang icewm-lite yast2-trans-en_US bundle-lang-common-en opensuse-manual_en bundle-lang-kde-en bundle-lang-gnome-en openSUSE-release openSUSE-release-ftp ault-base kernel-default-extra smolt virtualbox-ose-kmp-default ndiswrapper-kmp-default preload-kmp-default tango-icon-theme oxygen-icon-theme mono-core marble-data gnome-packagekit Mesa libqt4-x11 gnome-icon-theme xorg-x11-fonts-core ghostscript gio-branding-upstream grub grub2 grub2-branding-openSUSE plymouth-branding-openSUSE kdebase4-workspace-branding-openSUSE kdebase4-workspace libQtWebKit4 opensuse-startup_en glibc-locale; do
            grep -vx $i $file > t && mv t $file
	done
	grep -v patterns-openSUSE $file > t && mv t $file
    done

    diff -u output/opensuse/$proj/kde4_cd.$arch.list output/opensuse/$proj/kde4_cd-default.$arch.list | grep -v +++ | grep ^+ || true
    diff -u output/opensuse/$proj/gnome_cd.$arch.list output/opensuse/$proj/gnome_cd-default.$arch.list | grep -v +++ | grep ^+ || true
    
    ./gen.pl opensuse/$proj/promo_dvd $arch "$proj"
    ./gen.pl opensuse/$proj/dvd-addon_lang $arch "$proj"

done

./split_dvd9.sh output/opensuse/$proj/dvd9-i586.list output/opensuse/$proj/dvd9-x86_64.list output/opensuse/$proj/dvd9-all.list output/opensuse/$proj/dvd9-only_i586.list output/opensuse/$proj/dvd9-only_x86_64.list

diff output/opensuse/$proj/nonoss.deps.i586.list output/opensuse/$proj/nonoss.deps.x86_64.list | grep '^>' | cut '-d ' -f2 > output/opensuse/$proj/nonoss.deps-x86_64.list
cat output/opensuse/$proj/nonoss.deps.i586.list output/opensuse/$proj/nonoss.deps.x86_64.list | sort | uniq -d > output/opensuse/$proj/nonoss.deps.list

diff output/opensuse/$proj/nonoss.i586.list output/opensuse/$proj/nonoss.x86_64.list | grep '^>' | cut '-d ' -f2 > output/opensuse/$proj/nonoss-x86_64.list
cat output/opensuse/$proj/nonoss.i586.list output/opensuse/$proj/nonoss.x86_64.list | sort | uniq -d > output/opensuse/$proj/nonoss.list

./langaddon.sh

