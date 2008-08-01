#!/bin/sh

./gen.sh sled-1 || exit 1
./gen.sh sled-2 || exit 1
for i in i586 x86_64 all; do
  cat sled-1.$i.list sled-2.$i.list | LC_ALL=C sort -u > sled-$i.list
done

./gen.sh kde4_cd || exit 1
./gen.sh kde4_cd-default || exit 1
./gen.sh kde3_cd
./gen.sh gnome_cd || exit 1
./gen.sh gnome_cd-default || exit 1

./gen.sh dvd5-1
./gen.sh dvd5-2
./gen.sh dvd5-3
for i in i586 x86_64 ppc all; do
  cat dvd5-1.$i.list dvd5-2.$i.list dvd5-3.$i.list | LC_ALL=C sort -u > dvd-$i.list
done
./gen.sh kde4_cd-base-default
./gen.sh gnome_cd-x11-default

echo "diffing"
for arch in i586 x86_64 ppc; do
   diff -u kde4_cd.$arch.list kde4_cd-default.$arch.list | grep -v +++ | grep ^+
   diff -u gnome_cd.$arch.list gnome_cd-default.$arch.list | grep -v +++ | grep ^+

  for i in kernel-default powersave suspend OpenOffice_org-icon-themes smartmontools gtk-lang gimp-lang vte-lang icewm-lite yast2-trans-en_US bundle-lang-common-en opensuse-manual_en bundle-lang-kde-en bundle-lang-gnome-en; do
    for f in gnome_cd-default kde4_cd-default gnome_cd-x11-default kde4_cd-base-default; do
      grep -vx $i $f.$arch.list > t && mv t $f.$arch.list
    done
  done
done

for i in kde4_cd*.list; do 
  cp $i ${i/kde4_cd/kde_cd}
done

./gen.sh promo_dvd
./gen.sh dvd5-addon_lang
./langaddon.sh

./gen.sh sles-1
./gen.sh sles-2
cat sles-*.all.list | LC_ALL=C sort -u > sles-all.list


