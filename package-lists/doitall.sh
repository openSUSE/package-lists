#! /bin/sh

svn up

diffonly=$1
if test -z "$diffonly" || test -d "$diffonly"; then
cd testtrack/
./update_full.sh obs-i586 obs-x86_64 obs-ppc
#./update_full.sh head-i586 head-x86_64 head-ppc head-ppc64 head-ia64 head-s390x
echo -n "updating patterns "
./unpack_patterns.sh $diffonly > patterns.log 2>&1
echo "done"
cd ..
./doit.sh
cd autobuild-lists/
./update_lists.sh
cd ..

fi

./difflist.sh

cd update-tests
./testall.sh
cd ..

diff=0
for arch in i586 x86_64; do
  for f in gnome_cd-default gnome_cd kde4_cd-default kde4_cd kde3_cd gnome_cd-x11-default kde4_cd-base-default; do
     if ! diff -u saved/$f.$arch.list $f.$arch.list ; then
        diff=1 
        break
     fi
     test "$diff" = 0 || break
  done
done

if test "$diff" = 1; then
   echo "no diff"
   tar cjf /package_lists/filelists.tar.bz2 *.list
   cp *.list saved
fi

set -e

./check_yast.sh dvd-i586.list __i386__
./check_yast.sh dvd-x86_64.list __x86_64__
./check_yast.sh dvd-ppc.list __powerpc__

./check_yast.sh sled-i586.list __i386__
./check_yast.sh sled-x86_64.list __x86_64__

(
./check_size.sh dvd-i586.list i586
./check_size.sh dvd-x86_64.list x86_64
./check_size.sh dvd-ppc.list ppc
./check_size.sh sled-i586.list i586
./check_size.sh sled-x86_64.list x86_64
) | tee sizes

./mk_group.sh dvd-ppc.list DVD-ppc osc/openSUSE\:11.1/_product/DVD5-ppc.group only_ppc
./mk_group.sh dvd-i586.list DVD-i586 osc/openSUSE\:11.1/_product/DVD5-i586.group only_i586
./mk_group.sh dvd-x86_64.list DVD-x86_64 osc/openSUSE\:11.1/_product/DVD5-x86_64.group only_x86_64
./mk_group.sh promo_dvd.i586.list REST-DVD-promo-i386 osc/openSUSE\:11.1/_product/DVD5-promo-i386.group
./mk_group.sh langaddon-all.list REST-DVD osc/openSUSE\:11.1/_product/DVD5-lang.group

# I wan't to review changes before submitting package lists -- cthiel
#./mk_group.sh sdk-i586.list sdk-i586 osc/SUSE\:Factory\:Head/_product/sdk-i586.group only_i586
#./mk_group.sh sdk-x86_64.list sdk-x86_64 osc/SUSE\:Factory\:Head/_product/sdk-x86_64.group only_x86_64
#./mk_group.sh sdk-ppc64.list sdk-ppc64 osc/SUSE\:Factory\:Head/_product/sdk-ppc64.group only_ppc64
#./mk_group.sh sdk-ia64.list sdk-ia64 osc/SUSE\:Factory\:Head/_product/sdk-ia64.group only_ia64
#./mk_group.sh sdk-s390x.list sdk-s390x osc/SUSE\:Factory\:Head/_product/sdk-s390x.group only_s390x

./mk_group.sh x11_cd.all.list DVD osc/YaST\:SVN/_product/DVD.group

svn commit -m "auto commit"
echo "all done"
