. ./options

mkdir -p osc
test -d osc/openSUSE:$proj/_product || ( cd osc; osc co openSUSE:$proj/_product )

./mk_group.sh output/opensuse/dvd-i586.list DVD-i586 osc/openSUSE:$proj/_product/DVD5-i586.group only_i586
./mk_group.sh output/opensuse/dvd-x86_64.list DVD-x86_64 osc/openSUSE:$proj/_product/DVD5-x86_64.group only_x86_64

./mk_group.sh output/opensuse/dvd9-only_i586.list DVD9-i586 osc/openSUSE:$proj/_product/DVD9-i586.group only_i586
./mk_group.sh output/opensuse/dvd9-only_x86_64.list DVD9-x86_64 osc/openSUSE:$proj/_product/DVD9-x86_64.group only_x86_64
./mk_group.sh output/opensuse/dvd9-all.list DVD9-biarch osc/openSUSE:$proj/_product/DVD9-biarch.group

./mk_group.sh output/opensuse/promo_dvd.i586.list REST-DVD-promo-i386 osc/openSUSE:$proj/_product/DVD5-promo-i386.group only_i586
./mk_group.sh output/opensuse/promo_dvd.x86_64.list REST-DVD-promo-x86_64 osc/openSUSE:$proj/_product/DVD5-promo-x86_64.group only_x86_64

./mk_group.sh output/opensuse/langaddon.i586.list REST-DVD-i586 osc/openSUSE:$proj/_product/DVD5-lang-i586.group only_i586
./mk_group.sh output/opensuse/langaddon.x86_64.list REST-DVD-x86_64 osc/openSUSE:$proj/_product/DVD5-lang-x86_64.group only_x86_64

./mk_group.sh output/opensuse/nonoss.list Addon-NonOss osc/openSUSE:$proj/_product/openSUSE-Addon-NonOss.group
./mk_group.sh output/opensuse/nonoss-x86_64.list Addon-NonOss-x86_64 osc/openSUSE:$proj/_product/openSUSE-Addon-NonOss-x86_64.group only_x86_64
./mk_group.sh output/opensuse/nonoss.deps.list Addon-NonOss-Deps osc/openSUSE:$proj/_product/openSUSE-Addon-NonOss-Deps.group
./mk_group.sh output/opensuse/nonoss.deps-x86_64.list Addon-NonOss-Deps-x86_64 osc/openSUSE:$proj/_product/openSUSE-Addon-NonOss-Deps-x86_64.group only_x86_64

( cd osc/openSUSE:$proj/_product/ && osc ci -m "auto update" > /dev/null )

test -d osc/openSUSE:$proj:Live || (cd osc; osc co openSUSE:$proj:Live)

osc -q up -u osc/openSUSE:$proj:Live/package-lists-images.*  > /dev/null
cp -a output/opensuse/*default.i586.list osc/openSUSE:$proj:Live/package-lists-images.i586
cp -a output/opensuse/*default.x86_64.list osc/openSUSE:$proj:Live/package-lists-images.x86_64

osc -q up -u osc/openSUSE:$proj:Live/package-lists-kde.* > /dev/null
cp -a output/opensuse/kde4_cd.i586.list osc/openSUSE:$proj:Live/package-lists-kde.i586/packagelist
cp -a output/opensuse/kde4_cd.x86_64.list osc/openSUSE:$proj:Live/package-lists-kde.x86_64/packagelist

osc -q up -u osc/openSUSE:$proj:Live/package-lists-gnome.* > /dev/null
cp -a output/opensuse/gnome_cd.i586.list osc/openSUSE:$proj:Live/package-lists-gnome.i586/packagelist
cp -a output/opensuse/gnome_cd.x86_64.list osc/openSUSE:$proj:Live/package-lists-gnome.x86_64/packagelist

osc -q up -u osc/openSUSE:$proj:Live/package-lists-x11.* > /dev/null
cp -a output/opensuse/x11_cd.i586.list osc/openSUSE:$proj:Live/package-lists-x11.i586/packagelist
cp -a output/opensuse/x11_cd.x86_64.list osc/openSUSE:$proj:Live/package-lists-x11.x86_64/packagelist

osc -q ci -m "auto update" osc/openSUSE:$proj:Live/package-lists-* | grep -v nothing

installcheck x86_64 --withobsoletes trees/openSUSE:$proj-standard-x86_64.solv > openSUSE:$proj.installcheck
osc api -X PUT -f openSUSE:$proj.installcheck  /source/openSUSE:$proj:Staging/dashboard/installcheck
