#!/bin/sh

. options

for arch in i586 x86_64; do

  create_solv.pl $proj standard $arch
  create_solv.pl $proj:NonFree standard $arch

  case $file in
    opensuse/dvd-nonoss*)
       grep -v libqt opensuse/dvd-1.xml.in > opensuse/dvd-nonoss.xml.in
       installcheck $i testtrack/full-nf-$tree-$i/suse/setup/descr/packages | grep "nothing provides" | sed -e 's,.*nothing provides ,,; s, needed by.*,,' | sort -u | while read d; do
         sed -i -e "s,<!-- HOOK_FOR_NONOSS -->,<!-- HOOK_FOR_NONOSS -->\n<addRequire name='$d'/>," opensuse/dvd-nonoss.xml.in
       done
       ;;
  esac

    ./gen.sh opensuse/kde4_cd $arch
    ./gen.sh opensuse/kde4_cd-default $arch
    ./gen.sh opensuse/gnome_cd $arch
    ./gen.sh opensuse/gnome_cd-default $arch 

    ./gen.sh opensuse/dvd-1 $arch
    ./gen.sh opensuse/dvd-2 $arch
    ./gen.sh opensuse/dvd-3 $arch
    ./gen.sh opensuse/dvd-base $arch
    ./gen.sh opensuse/dvd9 $arch

    cat output/opensuse/dvd-1.$arch.list output/opensuse/dvd-2.$arch.list output/opensuse/dvd-3.$arch.list output/opensuse/dvd-base.$arch.list | LC_ALL=C sort -u > output/opensuse/dvd-$arch.list
    cat output/opensuse/dvd-$arch.list output/opensuse/dvd9.$arch.list | LC_ALL=C sort -u > output/opensuse/dvd9-$arch.list

    ./gen.sh opensuse/kde4_cd-base-default $arch
    ./gen.sh opensuse/kde4_cd-unstable $arch
    ./gen.sh opensuse/gnome_cd-nobundles $arch
    ./gen.sh opensuse/kde4_cd-nobundles $arch
    ./gen.sh opensuse/gnome_cd-x11-default $arch
    ./gen.sh opensuse/x11_cd $arch
    ./gen.sh opensuse/x11_cd-initrd $arch

  if echo $file | grep -q -- "-default"; then
     for i in kernel-default powersave suspend OpenOffice_org-icon-themes smartmontools gtk-lang gimp-lang vte-lang icewm-lite yast2-trans-en_US bundle-lang-common-en opensuse-manual_en bundle-lang-kde-en bundle-lang-gnome-en openSUSE-release openSUSE-release-ftp kernel-default-base kernel-default-extra smolt virtualbox-ose-kmp-default ndiswrapper-kmp-default preload-kmp-default tango-icon-theme oxygen-icon-theme mono-core marble-data gnome-packagekit Mesa libqt4-x11 gnome-icon-theme xorg-x11-fonts-core ghostscript gio-branding-upstream grub grub2 grub2-branding-openSUSE plymouth-branding-openSUSE kdebase4-workspace-branding-openSUSE kdebase4-workspace libQtWebKit4 opensuse-startup_en glibc-locale; do
          grep -vx $i output/$file.$GEN_ARCH.list > t && mv t output/$file.$GEN_ARCH.list
     done
     grep -v patterns-openSUSE output/$file.$GEN_ARCH.list > t && mv t output/$file.$GEN_ARCH.list
  fi
  if test "$file" = "opensuse/x11_cd-initrd"; then
      grep -vx openSUSE-release-ftp output/$file.$GEN_ARCH.list > t && mv t output/$file.$GEN_ARCH.list
  fi

    ./gen.sh opensuse/dvd-nonoss $arch
    
    diff -u output/opensuse/kde4_cd.$arch.list output/opensuse/kde4_cd-default.$arch.list | grep -v +++ | grep ^+
    diff -u output/opensuse/gnome_cd.$arch.list output/opensuse/gnome_cd-default.$arch.list | grep -v +++ | grep ^+
    
    ./gen.sh opensuse/promo_dvd $arch
    ./gen.sh opensuse/dvd-addon_lang $arch
done

./nonoss.sh
./langaddon.sh

