#!/bin/sh

svn up /home/pattern

rm -rf /tmp/pattern*

sh ../prepare_patterns.sh i586 i386
sh ../prepare_patterns.sh x86_64 x86_64
sh ../prepare_patterns.sh ppc powerpc


for arch in i586 x86_64 ppc; do
for i in kde4_cd kde3_cd kde4_cd_non_oss kde3_cd_non_oss gnome_cd gnome_cd_non_oss dvd5 promo_dvd;
do
  rm -rf $i.$arch
done
done

copy()
{
    file=$1
    dir=`dirname $file`
    dir=`echo $dir | sed -e "s,.*/CD1,CD1,"` 
    mkdir -p $2/$dir
    cp -a $file $2/$dir
}

for flav in kde3 kde4 gnome; do
  for arch in i586 x86_64 ppc; do
    copy /tmp/patterns.$arch/CD1/suse/setup/descr/"$flav"_cd-*.pat "$flav"_cd.$arch

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

