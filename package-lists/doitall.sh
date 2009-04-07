#! /bin/sh

svn up

diffonly=$1
if test -z "$diffonly" || test -d "$diffonly"; then
   cd testtrack/
   ./update_full.sh obs-i586 obs-x86_64 # obs-ppc
   #./update_full.sh head-i586 head-x86_64 head-ppc64 head-ia64 head-s390x
   #./update_full.sh ibs-i586 ibs-x86_64 ibs-ppc64 ibs-ia64 ibs-s390x
   #./update_full.sh sle11-i586 sle11-x86_64 sle11-ppc64 sle11-ia64 sle11-s390x
   echo -n "updating patterns "
   ./unpack_patterns.sh $diffonly > patterns.log 2>&1
   echo "done"
   cd ..
   internals=`pdb query --filter status:internal`
   test -n "$internals" || exit 1

   sh ./create_locks.sh $internals > output/pdb_internals.xml
   sh ./create_locks.sh `pdb query --filter status:candidate` > output/pdb_candidates.xml
   sh ./create_locks.sh `pdb query --filter status:frozen` > output/pdb_frozen.xml
   ./doit.sh
fi

cd update-tests
./testall.sh
cd ..

diff=0
for arch in i586 x86_64; do
  for f in gnome_cd-default gnome_cd kde4_cd-default kde4_cd kde3_cd gnome_cd-x11-default kde4_cd-base-default x11_cd; do
     if ! diff -u saved/$f.$arch.list output/opensuse/$f.$arch.list ; then
        diff=1 
        break
     fi
     test "$diff" = 0 || break
  done
done

if test "$diff" = 1; then
   echo "no diff"
   tar cjf /package_lists/filelists.tar.bz2 output/opensuse/*_cd*.list
   cp output/opensuse/*.list saved
fi

set -e

./check_yast.sh output/opensuse/dvd-i586.list __i386__
./check_yast.sh output/opensuse/dvd-x86_64.list __x86_64__
./check_yast.sh output/opensuse/dvd-ppc.list __powerpc__

#./check_yast.sh output/sled-i586.list __i386__
#./check_yast.sh output/sled-x86_64.list __x86_64__

(
./check_size.sh output/opensuse/dvd-i586.list i586
./check_size.sh output/opensuse/dvd-x86_64.list x86_64
./check_size.sh output/opensuse/dvd-ppc.list ppc
#./check_size.sh output/sled-i586.list i586
#./check_size.sh output/sled-x86_64.list x86_64
) | tee sizes

list=`(pdb query --filter status:production,ProdOnly:sles_only; pdb query --filter status:frozen; pdb query --filter status:internal) | LC_ALL=C sort -u`
: > output/not_for_opensuse.list
for i in $list; do 
  test -f testtrack/full-obs-i586/susex/i586/$i.rpm || continue
  echo $i >> output/not_for_opensuse.list
done

./mk_group.sh output/not_for_opensuse.list FROZEN osc/openSUSE\:Factory/_product/FROZEN.group drop_from_ftp
./mk_group.sh output/opensuse/dvd-ppc.list DVD-ppc osc/openSUSE\:Factory/_product/DVD5-ppc.group only_ppc
./mk_group.sh output/opensuse/dvd-i586.list DVD-i586 osc/openSUSE\:Factory/_product/DVD5-i586.group only_i586
./mk_group.sh output/opensuse/dvd-x86_64.list DVD-x86_64 osc/openSUSE\:Factory/_product/DVD5-x86_64.group only_x86_64
./mk_group.sh output/opensuse/promo_dvd.i586.list REST-DVD-promo-i386 osc/openSUSE\:Factory/_product/DVD5-promo-i386.group
./mk_group.sh output/opensuse/langaddon-all.list REST-DVD osc/openSUSE\:Factory/_product/DVD5-lang.group
( cd osc/openSUSE\:Factory/_product/ && osc ci -m "auto update" )

if false; then
./mk_group.sh output/sdk-i586.list sdk-i586 osc/SUSE:SLE-11:GA/_product/sdk-i586.group only_i586
./mk_group.sh output/sdk-x86_64.list sdk-x86_64 osc/SUSE:SLE-11:GA/_product/sdk-x86_64.group only_x86_64
./mk_group.sh output/sdk-ppc64.list sdk-ppc64 osc/SUSE:SLE-11:GA/_product/sdk-ppc64.group only_ppc64
./mk_group.sh output/sdk-ia64.list sdk-ia64 osc/SUSE:SLE-11:GA/_product/sdk-ia64.group only_ia64
./mk_group.sh output/sdk-s390x.list sdk-s390x osc/SUSE:SLE-11:GA/_product/sdk-s390x.group only_s390x
fi

./mk_group.sh output/opensuse/x11_cd.all.list DVD osc/YaST\:SVN/_product/DVD.group
(cd osc/YaST\:SVN/_product/ && osc ci -m "auto update")

#./sled.sh > /package_lists/purely_for_behlert

svn commit -m "auto commit"
echo "all done"

