#!/bin/sh

echo "kde-cd:"
./gen2.sh kde-cd
./gen2.sh kde-cd-non_oss
echo "gnome-cd:"
./gen2.sh gnome-cd
./gen2.sh gnome-cd-non_oss

./non_oss.sh
./join.sh

echo "dvd5:"
./gen2.sh dvd5
./gen2.sh dvd5-2

echo "language addon:"
./gen2.sh dvd5-addon_lang

./join.sh
./langaddon.sh
