#!/bin/sh

. ./options
export LC_ALL=C

grep -v openSUSE-release osc/openSUSE:Factory/_product/NON_FTP_PACKAGES.group | grep 'package name=' | \
   sed -e 's,.*package name=",job lock name ,; s,"/>,,' > opensuse/non_ftp_packages

for arch in i586 x86_64; do

    perl create_solv.pl openSUSE:$proj standard $arch
    perl create_solv.pl openSUSE:$proj:NonFree standard $arch

   # installcheck $arch trees/openSUSE:$proj:NonFree-standard-$arch.solv | grep "nothing provides" | \
#	sed -e 's,^.*nothing provides ,job install provides ,; s, needed by.*,,' | sort -u > opensuse/dvd-nonoss-deps-$arch

    ./gen.pl opensuse/kde4_cd $arch
    ./gen.pl opensuse/kde4_cd-default $arch
    ./gen.pl opensuse/gnome_cd $arch
    ./gen.pl opensuse/gnome_cd-default $arch 

    # first flash
    : > opensuse/dvd-1.$arch.suggests
    if ./gen.pl opensuse/dvd-1 $arch; then
    
      # then readd
      mv output/opensuse/dvd-1.$arch.suggests opensuse/dvd-1.$arch.suggests
      ./gen.pl opensuse/dvd-1 $arch
    fi

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

    dumpsolv trees/openSUSE:$proj:NonFree-standard-$arch.solv | grep solvable:name: | sed -e 's,.*: ,,' | sort > output/opensuse/nonoss.$arch.list
    echo "repo nonfree-standard-$arch 0 solv trees/openSUSE:Factory:NonFree-standard-$arch.solv" >  opensuse/dvd-nonoss
    echo '#INCLUDE dvd-1' >>  opensuse/dvd-nonoss
    for pkg in $(grep -v openSUSE output/opensuse/nonoss.$arch.list); do 
      echo "job install name $pkg" >> opensuse/dvd-nonoss
    done
    ./gen.pl opensuse/dvd-nonoss $arch
    ( diff output/opensuse/dvd-1.$arch.list output/opensuse/dvd-nonoss.$arch.list | grep '^>' | cut '-d ' -f2 ;
      cat output/opensuse/nonoss.$arch.list ) | sort | uniq -u  > output/opensuse/nonoss.deps.$arch.list

    for file in output/opensuse/*default.$arch.list; do
	for i in kernel-default libyui-gtk-pkg6 libyui-gtk6 powersave suspend OpenOffice_org-icon-themes smartmontools gtk-lang gimp-lang vte-lang icewm-lite yast2-trans-en_US bundle-lang-common-en opensuse-manual_en bundle-lang-kde-en bundle-lang-gnome-en openSUSE-release openSUSE-release-ftp ault-base kernel-default-extra smolt virtualbox-ose-kmp-default ndiswrapper-kmp-default preload-kmp-default tango-icon-theme oxygen-icon-theme mono-core marble-data gnome-packagekit Mesa libqt4-x11 gnome-icon-theme xorg-x11-fonts-core ghostscript gio-branding-upstream grub grub2 grub2-branding-openSUSE plymouth-branding-openSUSE kdebase4-workspace-branding-openSUSE kdebase4-workspace libQtWebKit4 opensuse-startup_en glibc-locale; do
            grep -vx $i $file > t && mv t $file
	done
	grep -v patterns-openSUSE $file > t && mv t $file
    done

    diff -u output/opensuse/kde4_cd.$arch.list output/opensuse/kde4_cd-default.$arch.list | grep -v +++ | grep ^+
    diff -u output/opensuse/gnome_cd.$arch.list output/opensuse/gnome_cd-default.$arch.list | grep -v +++ | grep ^+
    
    ./gen.pl opensuse/promo_dvd $arch
    ./gen.pl opensuse/dvd-addon_lang $arch

done

./split_dvd9.sh output/opensuse/dvd9-i586.list output/opensuse/dvd9-x86_64.list output/opensuse/dvd9-all.list output/opensuse/dvd9-only_i586.list output/opensuse/dvd9-only_x86_64.list

diff output/opensuse/nonoss.deps.i586.list output/opensuse/nonoss.deps.x86_64.list | grep '^>' | cut '-d ' -f2 > output/opensuse/nonoss.deps-x86_64.list
cat output/opensuse/nonoss.deps.i586.list output/opensuse/nonoss.deps.x86_64.list | sort | uniq -d > output/opensuse/nonoss.deps.list

diff output/opensuse/nonoss.i586.list output/opensuse/nonoss.x86_64.list | grep '^>' | cut '-d ' -f2 > output/opensuse/nonoss-x86_64.list
cat output/opensuse/nonoss.i586.list output/opensuse/nonoss.x86_64.list | sort | uniq -d > output/opensuse/nonoss.list

./langaddon.sh

