#!/bin/sh

svn up /home/pattern

arg=all
if test -n "$1"; then
  arg=$1
fi

copy()
{
    file=$1
    dir=`dirname $file`
    dir=`echo $dir | sed -e "s,.*/CD1,CD1,"`
    mkdir -p $2/$dir
    cp -a $file $2/$dir
}

if test $arg = openSUSE -o $arg = all; then
rm -rf /tmp/pattern*

sh ../prepare_patterns.sh i586 i386 openSUSE
sh ../prepare_patterns.sh x86_64 x86_64 openSUSE
sh ../prepare_patterns.sh ppc powerpc openSUSE

for flav in kde3 kde4 gnome x11; do
  for arch in i586 x86_64 ppc; do
    rm -rf "$flav"_cd.$arch
    copy /tmp/patterns.$arch/CD1/suse/setup/descr/"$flav"_cd-*.pat "$flav"_cd.$arch

    rm -rf "$flav"_cd_non_oss.$arch
    copy /tmp/patterns.$arch/CD1/suse/setup/descr/"$flav"_cd-*.pat "$flav"_cd_non_oss.$arch
    copy /tmp/patterns.$arch/CD1/suse/setup/descr/non_oss-*.pat "$flav"_cd_non_oss.$arch

    for i in "$flav"_cd_non_oss.$arch/CD1/suse/setup/descr/non_oss*pat; do 
      sed -i -e "s,Psg,Prc," $i
    done 
  done
done

for arch in i586 x86_64 ppc; do
  copy /tmp/patterns.$arch/CD1/suse/setup/descr/dvd-*.pat dvd5.$arch
  copy /tmp/patterns.$arch/CD1/suse/setup/descr/promo_dvd-*.pat promo_dvd.$arch
  copy /tmp/patterns.$arch/CD1/suse/setup/descr/non_oss-*.pat dvd5.$arch
  copy /tmp/patterns.$arch/CD1/suse/setup/descr/non_oss-*.pat promo_dvd.$arch
done
fi

if test $arg = sled -o $arg = all; then
rm -rf /tmp/pattern*
sh ../prepare_patterns.sh i586 i386 sled
sh ../prepare_patterns.sh x86_64 x86_64 sled

for arch in i586 x86_64; do
  copy /tmp/patterns.$arch/CD1/suse/setup/descr/sled-*.pat sled.$arch
done
fi

if test $arg = sles -o $arg = all; then
rm -rf /tmp/pattern*
sh ../prepare_patterns.sh i586 i386 sles
sh ../prepare_patterns.sh x86_64 x86_64 sles
sh ../prepare_patterns.sh ppc powerpc sles
sh ../prepare_patterns.sh ppc64 powerpc sles
sh ../prepare_patterns.sh ia64 ia64 sles

for arch in i586 x86_64 ppc ppc64 ia64; do
  copy /tmp/patterns.$arch/CD1/suse/setup/descr/*.pat sles.$arch
done

fi

if test $arg = sdk -o $arg = all; then
rm -rf /tmp/pattern*
sh ../prepare_patterns.sh i586 i386 sdk
sh ../prepare_patterns.sh x86_64 x86_64 sdk
sh ../prepare_patterns.sh ppc powerpc sdk
sh ../prepare_patterns.sh ppc64 powerpc sdk
sh ../prepare_patterns.sh ia64 ia64 sdk

for arch in i586 x86_64 ppc ppc64 ia64; do
  copy /tmp/patterns.$arch/CD1/suse/setup/descr/sdk-*.pat sdk.$arch
done

fi


