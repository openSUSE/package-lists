#!/bin/sh

echo "dvd5:"
./gen2.sh dvd5
./gen2.sh dvd5-2

echo "language addon:"
./gen2.sh dvd5-addon_lang

echo "kde-cd:"
./gen2.sh kde-cd
./gen2.sh kde-cd-non_oss
echo "gnome-cd:"
./gen2.sh gnome-cd
./gen2.sh gnome-cd-non_oss

./join.sh
./non_oss.sh
./langaddon.sh
