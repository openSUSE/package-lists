#! /bin/sh

proj=$1
test -n "$proj" || proj=Factory

case $proj in
	Factory) arches="i586 x86_64"
		repo="standard"
		;;
	Leap:42.3) arches="x86_64"
            repo="standard"
                ;;
	Leap:42.*:Ports) arches="ppc64le aarch64"
            repo="ports"
                ;;
	Factory:PowerPC) arches="ppc64 ppc64le"
			repo="standard"
		;;
	Factory:ARM)
		arches="aarch64"
		repo="standard"
		;;
esac

mkdir -p osc
test -d osc/openSUSE:$proj/_product || ( cd osc; osc co openSUSE:$proj/_product )

for arch in $arches; do
    ./mk_group.sh output/opensuse/$proj/dvd-$arch.list DVD-$arch osc/openSUSE:$proj/_product/DVD5-$arch.group only_$arch

    #if [ "$arch" = "i586" -o "$arch" = "x86_64" ];then
      #./mk_group.sh output/opensuse/$proj/dvd9-only_$arch.list DVD9-$arch osc/openSUSE:$proj/_product/DVD9-$arch.group only_$arch
      #./mk_group.sh output/opensuse/$proj/promo_dvd.$arch.list REST-DVD-promo-$arch osc/openSUSE:$proj/_product/DVD5-promo-$arch.group only_$arch
      #./mk_group.sh output/opensuse/$proj/langaddon.$arch.list REST-DVD-$arch osc/openSUSE:$proj/_product/DVD5-lang-$arch.group only_$arch
    #fi
    if [ "$arch" = "x86_64" ];then
      #./mk_group.sh output/opensuse/$proj/dvd9-all.list DVD9-biarch osc/openSUSE:$proj/_product/DVD9-biarch.group
      ./mk_group.sh output/opensuse/$proj/nonoss.list Addon-NonOss osc/openSUSE:$proj/_product/openSUSE-Addon-NonOss.group
      ./mk_group.sh output/opensuse/$proj/nonoss-$arch.list Addon-NonOss-$arch osc/openSUSE:$proj/_product/openSUSE-Addon-NonOss-$arch.group only_$arch
      ./mk_group.sh output/opensuse/$proj/nonoss.deps.list Addon-NonOss-Deps osc/openSUSE:$proj/_product/openSUSE-Addon-NonOss-Deps.group
      ./mk_group.sh output/opensuse/$proj/nonoss.deps-$arch.list Addon-NonOss-Deps-$arch osc/openSUSE:$proj/_product/openSUSE-Addon-NonOss-Deps-$arch.group only_$arch
      #if [ "$proj" = "Factory" ]; then
      #  ./mk_group.sh output/opensuse/$proj/dvd-kubic.$arch.list openSUSE-Kubic osc/openSUSE:$proj/_product/openSUSE-Kubic.group
      #fi
    fi
done

( cd osc/openSUSE:$proj/_product/ && osc ci -m "auto update" > /dev/null )

if [ "$arches" = "i586 x86_64" ];then
   test -d osc/openSUSE:$proj:Live || (cd osc; osc co -e openSUSE:$proj:Live)

   osc -q up -u osc/openSUSE:$proj:Live/package-lists-images.*  > /dev/null
   osc -q up -u osc/openSUSE:$proj:Live/package-lists-kde.* > /dev/null
   osc -q up -u osc/openSUSE:$proj:Live/package-lists-gnome.* > /dev/null
   osc -q up -u osc/openSUSE:$proj:Live/package-lists-x11.* > /dev/null
   for arch in $arches; do
       cp -a output/opensuse/$proj/*default.$arch.list osc/openSUSE:$proj:Live/package-lists-images.$arch
       cp -a output/opensuse/$proj/kde4_cd.$arch.list osc/openSUSE:$proj:Live/package-lists-kde.$arch/packagelist
       cp -a output/opensuse/$proj/gnome_cd.$arch.list osc/openSUSE:$proj:Live/package-lists-gnome.$arch/packagelist
       cp -a output/opensuse/$proj/x11_cd.$arch.list osc/openSUSE:$proj:Live/package-lists-x11.$arch/packagelist
   done
   osc -q ci -m "auto update" osc/openSUSE:$proj:Live/package-lists-* | grep -v nothing
fi

if [ "$proj" = "Leap:42.3" ]; then
  test -d osc/openSUSE:$proj/package-lists-openSUSE-images || ( cd osc; osc co openSUSE:$proj/package-lists-openSUSE-images )
  osc -q up osc/openSUSE:$proj/package-lists-openSUSE-images > /dev/null
  for file in gnome_cd-default gnome_cd-x11-default kde4_cd-base-default kde4_cd-default; do
    cp output/opensuse/$proj/${file}.${arch}.list osc/openSUSE:$proj/package-lists-openSUSE-images/${file}.${arch}.list
  done
  osc -q ci -m "auto update" osc/openSUSE:$proj/package-lists-openSUSE-images | grep -v nothing
fi

if [ -f trees/openSUSE:$proj-$repo-x86_64.solv ]; then
   installcheck x86_64 --withobsoletes trees/openSUSE:$proj-$repo-x86_64.solv > openSUSE:$proj.installcheck
   osc api -X PUT -f openSUSE:$proj.installcheck  /source/openSUSE:$proj:Staging/dashboard/installcheck
fi
