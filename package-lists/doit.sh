#!/bin/sh

echo "kde_cd:"
./gen.sh kde_cd
echo "kde_cd_non_oss:"
./gen.sh kde_cd_non_oss
echo "gnome_cd:"
./gen.sh gnome_cd
echo "gnome_cd_non-oss:"
./gen.sh gnome_cd_non_oss

echo "non-oss:"
./non_oss.sh

echo "dvd5:"
./gen.sh dvd5
./gen.sh dvd5-2

#echo "promo-dvd5:"
#./gen.sh dvd5-promo

echo "language addon:"
./gen.sh dvd5-addon_lang

./join.sh
./langaddon.sh
