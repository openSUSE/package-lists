#!/bin/sh

svn up /home/pattern

rm -rf /tmp/pattern*

sh ../prepare_patterns.sh i386
mv /tmp/patterns.i386 /tmp/patterns.i586
sh ../prepare_patterns.sh x86_64
sh ../prepare_patterns.sh ppc


for i in kde-cd.i586 kde-cd-non_oss.i586 kde-cd-non_oss.x86_64 kde-cd.x86_64 gnome-cd.i586 gnome-cd-non_oss.i586 gnome-cd-non_oss.x86_64 gnome-cd.x86_64 dvd5.i586 dvd5.ppc dvd5.x86_64;
do
  rm -rf $i/CD1
done

copy()
{
    file=$1
    dir=`dirname $file`
    dir=`echo $dir | sed -e "s,.*/CD1,CD1,"` 
    mkdir -p $2/$dir
    cp -a $file $2/$dir
}

for flav in kde gnome; do
  for arch in i586 x86_64 ppc; do
    copy /tmp/patterns.$arch/CD1/suse/setup/descr/"$flav"_cd-*.pat $flav-cd.$arch

    copy /tmp/patterns.$arch/CD1/suse/setup/descr/"$flav"_cd-*.pat $flav-cd-non_oss.$arch
    copy /tmp/patterns.$arch/CD1/suse/setup/descr/non_oss-*.pat $flav-cd-non_oss.$arch

    for i in $flav-cd-non_oss.$arch/CD1/suse/setup/descr/non_oss*pat; do 
      sed -i -e "s,Psg,Prc," $i
    done 
  done
done

for arch in i586 x86_64 ppc; do
  copy /tmp/patterns.$arch/CD1/suse/setup/descr/dvd-*.pat dvd5.$arch
  copy /tmp/patterns.$arch/CD1/suse/setup/descr/non_oss-*.pat dvd5.$arch
done

