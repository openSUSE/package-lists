#!/bin/sh

mbuild=$1

for i in kde-cd.i586 kde-cd-non_oss.i586 kde-cd-non_oss.x86_64 kde-cd.x86_64 gnome-cd.i586 gnome-cd-non_oss.i586 gnome-cd-non_oss.x86_64 gnome-cd.x86_64 dvd5.i586 dvd5.ppc dvd5.x86_64;
do
  rm -rf $i/CD1
done

pushd kde-cd.i586
  unrpm $mbuild/i386/patterns-openSUSE-KDE-cd*.rpm
popd

pushd kde-cd.x86_64
  unrpm $mbuild/x86_64/patterns-openSUSE-KDE-cd*.rpm
popd

pushd kde-cd-non_oss.i586
  unrpm $mbuild/i386/patterns-openSUSE-KDE-cd*.rpm
  unrpm $mbuild/i386/patterns-openSUSE-addon-non-oss*.rpm
  for i in CD1/suse/setup/descr/non_oss*pat; do sed -e "s,Psg,Prc," $i > $i.new && mv $i.new $i; done  
popd

pushd kde-cd-non_oss.x86_64
  unrpm $mbuild/x86_64/patterns-openSUSE-KDE-cd*.rpm
  unrpm $mbuild/x86_64/patterns-openSUSE-addon-non-oss*.rpm
  for i in CD1/suse/setup/descr/non_oss*pat; do sed -e "s,Psg,Prc," $i > $i.new && mv $i.new $i; done  
popd


pushd gnome-cd.i586
  unrpm $mbuild/i386/patterns-openSUSE-GNOME-cd*.rpm
popd

pushd gnome-cd.x86_64
  unrpm $mbuild/x86_64/patterns-openSUSE-GNOME-cd*.rpm
popd

pushd gnome-cd-non_oss.i586
  unrpm $mbuild/i386/patterns-openSUSE-GNOME-cd*.rpm
  unrpm $mbuild/i386/patterns-openSUSE-addon-non-oss*.rpm
  for i in CD1/suse/setup/descr/non_oss*pat; do sed -e "s,Psg,Prc," $i > $i.new && mv $i.new $i; done  
popd

pushd gnome-cd-non_oss.x86_64
  unrpm $mbuild/x86_64/patterns-openSUSE-GNOME-cd*.rpm
  unrpm $mbuild/x86_64/patterns-openSUSE-addon-non-oss*.rpm
  for i in CD1/suse/setup/descr/non_oss*pat; do sed -e "s,Psg,Prc," $i > $i.new && mv $i.new $i; done  
popd


pushd dvd5.i586
  unrpm $mbuild/i386/patterns-openSUSE-dvd5*.rpm
popd

pushd dvd5.x86_64
  unrpm $mbuild/x86_64/patterns-openSUSE-dvd5*.rpm
popd

pushd dvd5.ppc
  unrpm $mbuild/ppc/patterns-openSUSE-dvd5*.rpm
popd
