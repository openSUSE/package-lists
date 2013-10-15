#!/bin/sh

. ./options

GEN_ARCH="i586 x86_64"
BASEDIR=`pwd`
GEN_URL_i586="$BASEDIR/testtrack/full-$tree-i586"
GEN_URL_x86_64="$BASEDIR/testtrack/full-$tree-x86_64"
TESTTRACK="`pwd`/testtrack"

export LC_ALL=C

echo -n "processing $1"

if test -f config.sh; then
  . config.sh
fi

file=$1

# multiple setups (dvd5, dvd5-2, etc.)
base=${file/-*/}
base=`basename $base`

LOCK=
LOCK2=

if test -n "$2"; then
  GEN_ARCH=$2
fi

ret=0

prep_patterns()
{
  mkdir -p $TESTTRACK/CD1/suse/setup/descr/
  grep -v $1 $TESTTRACK/patterns/$base-*.$arch.pat > $TESTTRACK/CD1/suse/setup/descr/$base.$arch.pat
  pushd $TESTTRACK/CD1/suse/setup/descr/ > /dev/null
  : > patterns
  for i in *; do
    echo -n "META SHA1 ";
    sha1sum $i | awk '{ORS=""; print $1}';
    echo -n " "; basename $i;
    basename $i >> patterns
  done >> $TESTTRACK/CD1/content
  popd > /dev/null
  rm -f $TESTTRACK/CD1/content.asc
  gpg  --batch -a -b --sign $TESTTRACK/CD1/content
}

cp solver-system.xml output/`dirname $file`

for i in $GEN_ARCH;
do
  arch=$i
  echo -n " $arch"
  eval VAR="\$GEN_URL_${i}"

  case $file in
    opensuse/dvd-nonoss*)
       grep -v libqt opensuse/dvd-1.xml.in > opensuse/dvd-nonoss.xml.in
       installcheck $i testtrack/full-nf-$tree-$i/suse/setup/descr/packages | grep "nothing provides" | sed -e 's,.*nothing provides ,,; s, needed by.*,,' | sort -u | while read d; do
         sed -i -e "s,<!-- HOOK_FOR_NONOSS -->,<!-- HOOK_FOR_NONOSS -->\n<addRequire name='$d'/>," opensuse/dvd-nonoss.xml.in
       done
       ;;
  esac
  sed -e "s,GEN_ARCH,$i," -e "s,GEN_URL,dir://$TESTTRACK/CD1," $file.xml.in > output/$file.$arch.xml
  includes=`grep -- "-- INCLUDE" $file.xml.in | sed -e "s,.*INCLUDE *,,; s, .*,,"`
  for include in $includes; do 
        if test -f output/$include; then
           finclude=output/$include
        else
           finclude=`dirname $file`/$include
           if test -f output/$finclude; then
             finclude=output/$finclude
           fi
           if test ! -f $finclude; then
             echo "MISSING: $finclude"
             exit 1
           fi
        fi
        sed -i -e "/!-- INCLUDE $include -->/r $finclude" output/$file.$arch.xml 
  done
  fgrep -v "!$arch" output/$file.$arch.xml > $file.$arch.xml.new && mv $file.$arch.xml.new output/$file.$arch.xml

  rm -rf /tmp/myrepos /var/cache/zypp
  rm -rf $TESTTRACK/CD1
  mkdir -p $TESTTRACK/CD1
  cp -a $TESTTRACK/content.$arch.small $TESTTRACK/CD1/content
  cp -a $VAR/suse $TESTTRACK/CD1/
  cp -a $VAR/media.1 $TESTTRACK/CD1/
  
  prep_patterns patterns-openSUSE-

  export ZYPP_LIBSOLV_FULLLOG=1
  export ZYPP_FULLLOG=1
  export ZYPP_MODALIAS_SYSFS=/tmp
  /usr/lib/zypp/testsuite/bin/deptestomatic.multi output/$file.$arch.xml 2> output/$file.$arch.error > output/$file.$arch.output
  sed -n -e '1,/Other Valid Solution/p' output/$file.$arch.output | grep -v 'install pattern:' | grep -v 'install product:' | grep "> install.*\[tmp\]"  |\
      sed -e 's,>!> install \(.*\)-[^-]*-[^-]*$,\1,' > output/$file.$arch.list.new
  if test -s "output/$file.$arch.list.new"; then
     mv "output/$file.$arch.list.new" "output/$file.$arch.list"
   
     # now get the pattern packages too
     prep_patterns patterns-openSUSE-XX
     /usr/lib/zypp/testsuite/bin/deptestomatic.multi output/$file.$arch.xml > output/$file-XX.$arch.output 2> /dev/null
     sed -n -e '1,/Other Valid Solution/p' output/$file-XX.$arch.output | grep "> install patterns-openSUSE.*\[tmp\]"  |\
      sed -e 's,>!> install \(.*\)-[^-]*-[^-]*$,\1,' >> output/$file.$arch.list
     LC_ALL=C sort -u -o output/$file.$arch.list output/$file.$arch.list
  else
     rm "output/$file.$arch.list.new"
     grep -C5 Problem: output/$file.$arch.output
     fgrep "Unknown item" output/$file.$arch.error
     ret=1
     echo -n "!"
  fi

  #rm -rf $TESTTRACK/CD1

  if echo $file | grep -q -- "-default"; then
     for i in kernel-default powersave suspend OpenOffice_org-icon-themes smartmontools gtk-lang gimp-lang vte-lang icewm-lite yast2-trans-en_US bundle-lang-common-en opensuse-manual_en bundle-lang-kde-en bundle-lang-gnome-en openSUSE-release openSUSE-release-ftp kernel-default-base kernel-default-extra smolt virtualbox-ose-kmp-default ndiswrapper-kmp-default preload-kmp-default tango-icon-theme oxygen-icon-theme mono-core marble-data gnome-packagekit Mesa libqt4-x11 gnome-icon-theme xorg-x11-fonts-core ghostscript gio-branding-upstream grub grub2 grub2-branding-openSUSE plymouth-branding-openSUSE kdebase4-workspace-branding-openSUSE kdebase4-workspace libQtWebKit4 opensuse-startup_en; do
          grep -vx $i output/$file.$arch.list > t && mv t output/$file.$arch.list
     done
     grep -v patterns-openSUSE output/$file.$arch.list > t && mv t output/$file.$arch.list
  fi
  if test "$file" = "opensuse/x11_cd-initrd"; then
      grep -vx openSUSE-release-ftp output/$file.$arch.list > t && mv t output/$file.$arch.list
  fi
  
done

if test "$ret" = 1; then
  echo " failed"
else
  echo " done"
fi

rm -rf /tmp/myrepos
exit $ret

