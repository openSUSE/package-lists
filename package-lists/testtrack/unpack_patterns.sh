#!/bin/sh

mbuild=$1
if test -z "$mbuild"; then
   mbuild=/mounts/work/CDs/all
   dir_i586=$mbuild/full-i386/suse/i586
   dir_x86_64=$mbuild/full-x86_64/suse/x86_64
   dir_ppc=$mbuild/full-ppc/suse/ppc
else
   dir_i586=$mbuild/i386
   dir_x86_64=$mbuild/x86_64
   dir_ppc=$mbuild/ppc
fi

for i in kde-cd.i586 kde-cd-non_oss.i586 kde-cd-non_oss.x86_64 kde-cd.x86_64 gnome-cd.i586 gnome-cd-non_oss.i586 gnome-cd-non_oss.x86_64 gnome-cd.x86_64 dvd5.i586 dvd5.ppc dvd5.x86_64;
do
  rm -rf $i/CD1
done

if test -z `ls -1 $dir_i586/patterns-openSUSE-KDE-cd*.rpm 2> /dev/null`; then
  echo "No patterns: $dir_i586/patterns-openSUSE-KDE-cd*.rpm"
  exit 1
fi

pushd kde-cd.i586
  unrpm $dir_i586/patterns-openSUSE-KDE-cd*.rpm
popd

pushd kde-cd.x86_64
  unrpm $dir_x86_64/patterns-openSUSE-KDE-cd*.rpm
popd

pushd kde-cd-non_oss.i586
  unrpm $dir_i586/patterns-openSUSE-KDE-cd*.rpm
  unrpm $dir_i586/patterns-openSUSE-addon-non-oss*.rpm
  for i in CD1/suse/setup/descr/non_oss*pat; do sed -e "s,Psg,Prc," $i > $i.new && mv $i.new $i; done  
popd

pushd kde-cd-non_oss.x86_64
  unrpm $dir_x86_64/patterns-openSUSE-KDE-cd*.rpm
  unrpm $dir_x86_64/patterns-openSUSE-addon-non-oss*.rpm
  for i in CD1/suse/setup/descr/non_oss*pat; do sed -e "s,Psg,Prc," $i > $i.new && mv $i.new $i; done  
popd


pushd gnome-cd.i586
  unrpm $dir_i586/patterns-openSUSE-GNOME-cd*.rpm
popd

pushd gnome-cd.x86_64
  unrpm $dir_x86_64/patterns-openSUSE-GNOME-cd*.rpm
popd

pushd gnome-cd-non_oss.i586
  unrpm $dir_i586/patterns-openSUSE-GNOME-cd*.rpm
  unrpm $dir_i586/patterns-openSUSE-addon-non-oss*.rpm
  for i in CD1/suse/setup/descr/non_oss*pat; do sed -e "s,Psg,Prc," $i > $i.new && mv $i.new $i; done  
popd

pushd gnome-cd-non_oss.x86_64
  unrpm $dir_x86_64/patterns-openSUSE-GNOME-cd*.rpm
  unrpm $dir_x86_64/patterns-openSUSE-addon-non-oss*.rpm
  for i in CD1/suse/setup/descr/non_oss*pat; do sed -e "s,Psg,Prc," $i > $i.new && mv $i.new $i; done  
popd


pushd dvd5.i586
  unrpm `ls -1 $dir_i586/patterns-openSUSE.rpm $dir_i586/patterns-openSUSE-11*.i586.rpm 2> /dev/null`
popd

pushd dvd5.x86_64
  unrpm `ls -1 $dir_x86_64/patterns-openSUSE.rpm $dir_x86_64/patterns-openSUSE-11*.x86_64.rpm 2> /dev/null`
popd

pushd dvd5.ppc
  unrpm `ls -1 $dir_ppc/patterns-openSUSE.rpm $dir_ppc/patterns-openSUSE-11*.ppc.rpm 2> /dev/null`
popd
