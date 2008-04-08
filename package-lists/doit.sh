#!/bin/sh

echo "kde_cd:"
./gen.sh kde_cd || exit 1
echo "kde default:"
./gen.sh kde_cd-default || exit 1
echo "kde_cd_non_oss:"
./gen.sh kde_cd_non_oss
echo "gnome_cd:"
./gen.sh gnome_cd || exit 1
echo "gnome default:"
./gen.sh gnome_cd-default || exit 1
echo "gnome_cd_non-oss:"
./gen.sh gnome_cd_non_oss

echo "non-oss:"
./non_oss.sh

echo "dvd5:"
./gen.sh dvd5
./gen.sh dvd5-2
./gen.sh kde_cd-base-default
./gen.sh gnome_cd-x11-default

echo "diffing"
for arch in i586 x86_64 ppc; do
   diff -u kde_cd.$arch.list kde_cd-default.$arch.list | grep -v +++ | grep ^+
   diff -u gnome_cd.$arch.list gnome_cd-default.$arch.list | grep -v +++ | grep ^+

  for i in kernel-default powersave suspend OpenOffice_org-icon-themes smartmontools gtk-lang gimp-lang vte-lang icewm-lite yast2-trans-en_US bundle-lang-common-en opensuse-manual_en bundle-lang-kde-en bundle-lang-gnome-en; do
    for f in gnome_cd-default kde_cd-default gnome_cd-x11-default kde_cd-base-default; do
      grep -vx $i $f.$arch.list > t && mv t $f.$arch.list
    done
  done
done

diff -u kde_cd.i586.list kde_cd-default.i586.list | grep -v -- --- | grep ^- | cut -b2- > kde_cd2.i586.list

#echo "promo-dvd5:"
#./gen.sh dvd5-promo

echo "language addon:"
./gen.sh dvd5-addon_lang

./join.sh
./langaddon.sh
