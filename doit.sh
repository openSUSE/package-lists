#!/bin/bash

set -e
export LC_ALL=C

if [ -n "$1" ]; then
	export proj="$1"
else
        export proj="Factory"
fi

case $proj in
	Factory)arches="i586 x86_64"
		repo="standard"
		;;
        Leap:42.1) arches="x86_64"
                repo="standard"
                ;;
	Factory:PowerPC) arches="ppc64 ppc64le"
		repo="standard"
		;;
	Factory:ARM)
		arches="aarch64"
		repo="standard"
		;;
esac

is_x86(){
	case $1 in
		i586|x86_64) return 0;;
		aarch64|ppc64|ppc64le) return 1;;
	esac
}

echo "generate dvds for $proj $repo at "
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

for arch in $arches; do

    perl create_solv.pl openSUSE:$proj $repo $arch
    if $(is_x86 $arch);then
        perl create_solv.pl openSUSE:$proj:NonFree $repo $arch
    fi

    ./dump_supplements \
        trees/openSUSE:$proj-$repo-$arch.solv \
        > opensuse/$proj/all-supplements
        if $(is_x86 $arch);then
            ./dump_supplements \
                trees/openSUSE:$proj:NonFree-$repo-$arch.solv \
            >> opensuse/$proj/all-supplements
        fi

   # installcheck $arch trees/openSUSE:$proj:NonFree-$repo-$arch.solv | grep "nothing provides" | \
#	sed -e 's,^.*nothing provides ,job install provides ,; s, needed by.*,,' | sort -u > opensuse/$proj/dvd-nonoss-deps-$arch
   if $(is_x86 $arch) ;then
    ./gen.pl opensuse/$proj/kde4_cd $arch "$proj" $repo
    ./gen.pl opensuse/$proj/kde4_cd-default $arch "$proj" $repo
    ./gen.pl opensuse/$proj/gnome_cd $arch "$proj" $repo
    ./gen.pl opensuse/$proj/gnome_cd-default $arch "$proj" $repo

    ./gen.pl opensuse/$proj/kde4_cd-base-default $arch "$proj" $repo
    if test "$proj" = "Factory"; then
      ./gen.pl opensuse/$proj/kde4_cd-unstable $arch "$proj" $repo
      ./gen.pl opensuse/$proj/gnome_cd-nobundles $arch "$proj" $repo
      ./gen.pl opensuse/$proj/kde4_cd-nobundles $arch "$proj" $repo
      ./gen.pl opensuse/$proj/dvd9 $arch "$proj" $repo
    fi
    if test "$proj" = "Factory" -o "$proj" = "Leap:42.1"; then
      ./gen.pl opensuse/$proj/gnome_cd-x11-default $arch "$proj" $repo
      ./gen.pl opensuse/$proj/x11_cd $arch "$proj" $repo
    fi
   fi

   if test "$proj" = "Leap:42.1" ;then
     # As we do not have bundle-lang packages, we want to get rid of all -lang on the 'installation images' to save the space
     for file in gnome_cd-default gnome_cd-x11-default kde4_cd-base-default kde4_cd-default; do
       sed -i '/.*-lang$/d' output/opensuse/$proj/$file.${arch}.list
     done
   fi

    # first flash
    : > opensuse/$proj/dvd-1.$arch.suggests
    if ./gen.pl opensuse/$proj/dvd-1 $arch "$proj"; then

      # then readd
      mv output/opensuse/$proj/dvd-1.$arch.suggests opensuse/$proj/dvd-1.$arch.suggests
      ./gen.pl opensuse/$proj/dvd-1 $arch "$proj" $repo
    fi

    ./gen.pl opensuse/$proj/dvd-2 $arch "$proj" $repo
    ./gen.pl opensuse/$proj/dvd-3 $arch "$proj" $repo
    ./gen.pl opensuse/$proj/dvd-base $arch "$proj" $repo

    cat output/opensuse/$proj/dvd-1.$arch.list output/opensuse/$proj/dvd-2.$arch.list output/opensuse/$proj/dvd-3.$arch.list output/opensuse/$proj/dvd-base.$arch.list | LC_ALL=C sort -u > output/opensuse/$proj/dvd-$arch.list
    if $(is_x86 $arch); then
        cat output/opensuse/$proj/dvd-$arch.list output/opensuse/$proj/dvd9.$arch.list | LC_ALL=C sort -u > output/opensuse/$proj/dvd9-$arch.list

        dumpsolv trees/openSUSE:$proj:NonFree-$repo-$arch.solv | grep solvable:name: | sed -e 's,.*: ,,' | sort > output/opensuse/$proj/nonoss.$arch.list
        echo "repo nonfree-$repo-$arch 0 solv trees/openSUSE:$proj:NonFree-standard-$arch.solv" >  opensuse/$proj/dvd-nonoss
        echo '#INCLUDE dvd-1' >>  opensuse/$proj/dvd-nonoss
        for pkg in $(grep -v -e openSUSE -e libGLw output/opensuse/$proj/nonoss.$arch.list); do
           echo "job install name $pkg" >> opensuse/$proj/dvd-nonoss
        done
        if ./gen.pl opensuse/$proj/dvd-nonoss $arch "$proj" $repo; then
            ( diff output/opensuse/$proj/dvd-1.$arch.list output/opensuse/$proj/dvd-nonoss.$arch.list | grep '^>' | cut '-d ' -f2 ;
            cat output/opensuse/$proj/nonoss.$arch.list ) | sort | uniq -u  > output/opensuse/$proj/nonoss.deps.$arch.list
        fi

        for file in output/opensuse/$proj/*default.$arch.list; do
            for i in kernel-default libyui-gtk-pkg6 libyui-gtk6 powersave suspend OpenOffice_org-icon-themes smartmontools gtk-lang gimp-lang vte-lang icewm-lite yast2-trans-en_US bundle-lang-common-en opensuse-manual_en bundle-lang-kde-en bundle-lang-gnome-en openSUSE-release openSUSE-release-ftp ault-base kernel-default-extra smolt virtualbox-ose-kmp-default ndiswrapper-kmp-default preload-kmp-default tango-icon-theme oxygen-icon-theme mono-core marble-data gnome-packagekit Mesa libqt4-x11 gnome-icon-theme xorg-x11-fonts-core ghostscript gio-branding-upstream grub grub2 grub2-branding-openSUSE plymouth-branding-openSUSE kdebase4-workspace-branding-openSUSE kdebase4-workspace libQtWebKit4 opensuse-startup_en glibc-locale kdebase4-runtime cups breeze5-wallpapers yast2-branding-openSUSE libwebkit2gtk-4_0-37 libQt5WebKit5 ; do
                grep -vx $i $file > t && mv t $file
        done
            grep -v patterns-openSUSE $file > t && mv t $file
        done
        diff -u output/opensuse/$proj/kde4_cd.$arch.list output/opensuse/$proj/kde4_cd-default.$arch.list | grep -v +++ | grep ^+ || true
        diff -u output/opensuse/$proj/gnome_cd.$arch.list output/opensuse/$proj/gnome_cd-default.$arch.list | grep -v +++ | grep ^+ || true

       if test "$proj" = "Factory"; then
         ./gen.pl opensuse/$proj/promo_dvd $arch "$proj" $repo
         ./gen.pl opensuse/$proj/dvd-addon_lang $arch "$proj" $repo
       fi
    fi
done

if $(is_x86 $arch) && test "$proj" = "Factory" ;then
    ./split_dvd9.sh output/opensuse/$proj/dvd9-i586.list output/opensuse/$proj/dvd9-x86_64.list output/opensuse/$proj/dvd9-all.list output/opensuse/$proj/dvd9-only_i586.list output/opensuse/$proj/dvd9-only_x86_64.list

    diff output/opensuse/$proj/nonoss.deps.i586.list output/opensuse/$proj/nonoss.deps.x86_64.list | grep '^>' | cut '-d ' -f2 > output/opensuse/$proj/nonoss.deps-x86_64.list
    cat output/opensuse/$proj/nonoss.deps.i586.list output/opensuse/$proj/nonoss.deps.x86_64.list | sort | uniq -d > output/opensuse/$proj/nonoss.deps.list

    diff output/opensuse/$proj/nonoss.i586.list output/opensuse/$proj/nonoss.x86_64.list | grep '^>' | cut '-d ' -f2 > output/opensuse/$proj/nonoss-x86_64.list
    cat output/opensuse/$proj/nonoss.i586.list output/opensuse/$proj/nonoss.x86_64.list | sort | uniq -d > output/opensuse/$proj/nonoss.list

    ./langaddon.sh

fi
