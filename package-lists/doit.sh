#!/bin/sh

./gen2.sh dvd5
./gen2.sh dvd5-2

./gen2.sh dvd5-addon_lang

./gen2.sh kde-cd
./gen2.sh kde-cd-non_oss
./gen2.sh gnome-cd
./gen2.sh gnome-cd-non_oss

./join.sh
./non_oss.sh
./langaddon.sh

