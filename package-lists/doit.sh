#!/bin/sh

echo "kde-cd:"
./gen.sh kde-cd
./gen.sh kde-cd-non_oss
echo "gnome-cd:"
./gen.sh gnome-cd
./gen.sh gnome-cd-non_oss

./non_oss.sh
./join.sh

echo "dvd5:"
./gen.sh dvd5
./gen.sh dvd5-2

echo "promo-dvd5:"
./gen.sh dvd5-promo

echo "language addon:"
./gen.sh dvd5-addon_lang

./join.sh
./langaddon.sh
