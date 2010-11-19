set -e
export LC_ALL=C

project=openSUSE:Factory
repo=standard
arch=x86_64
dir=rebuilds
mdeps=/tmp/missingdeps

# can't help
sed -i -e '/nothing provides ctcs2 >= 0.1.6 needed by libmicro-ctcs-glue/d' /tmp/missingdeps

if test "$1" = "ppc"; then
  project="openSUSE:Factory:PowerPC"
  arch="ppc"
  dir=rebuildsppc
  mdeps=/tmp/missingdeps_ppc
fi
 
function maptosource {
 egrep 'package|subpkg|source' /tmp/builddep  | fgrep -B40 "<subpkg>$1</subpkg>" | fgrep '<source>'| tail -n 1 | sed -e 's, *<[/s]*ource>,,g'
}

function rebuildpacs {
 api="/build/$project/_result?repository=$repo"
 for i in $@; do 
  value="$(perl -MURI::Escape -e 'print uri_escape($ARGV[0]);' "$i")"
  api="$api&package=$value"
 done
 tpackages=`osc api $api | grep 'code="succeeded"' | sed -e 's,.*package=",,; s,".*,,' | sort -u`
 api=
 for i in $tpackages; do 
  if test -f "$dir/$i"; then
    echo "skipping to rebuild $i"
    continue
  fi
  echo "rebuilding $i"
  value="$(perl -MURI::Escape -e 'print uri_escape($ARGV[0]);' "$i")"
  api="$api&package=$value"
  touch "$dir/$i"
 done
 if test -n "$api"; then
   #echo "$api"
   osc api -m POST "/build/$project?cmd=rebuild&repository=$repo$api"
 fi
}

osc api /build/$project/$repo/$arch/_builddepinfo > /tmp/builddep

: > /tmp/torebuild
touch $dir/package-lists-openSUSE
for package in installation-images rpmlint-mini bundle-lang-common bundle-lang-kde bundle-lang-gnome bundle-lang-gnome-extras; do
  osc buildinfo $project $package $repo $arch | grep 'bdep name' > $dir/$package.new || true
  if cmp -s $dir/$package.old $dir/$package.new; then
    echo $package >> /tmp/torebuild
    rm -f $dir/$package
  fi
done
find $dir -cmin +1500 -print0 | xargs -0 --no-run-if-empty rm -v || true

missingdeps=`sed -e 's,.*needed by ,,' $mdeps | sort -u`
for i in $missingdeps; do
  maptosource $i >> /tmp/torebuild
done
sort -o /tmp/torebuild -u /tmp/torebuild

newfiles=`ls -1 $dir/*.new 2> /dev/null`
for i in $newfiles; do
  mv -vf $i ${i/.new/.old}
done

split -l 50 /tmp/torebuild rebuilds_
for file in rebuilds_*; do
 rebuildpacs `cat $file`
 rm -f $file
done

