set -e
export LC_ALL=C

function maptosource {
 egrep 'package|subpkg|source' /tmp/builddep  | fgrep -B40 "<subpkg>$1</subpkg>" | fgrep '<source>'| tail -n 1 | sed -e 's, *<[/s]*ource>,,g'
}

function rebuildpacs {
 api='/build/openSUSE:Factory/_result?repository=standard'
 for i in $@; do 
  value="$(perl -MURI::Escape -e 'print uri_escape($ARGV[0]);' "$i")"
  api="$api&package=$value"
 done
 tpackages=`osc api $api | grep 'code="succeeded"' | sed -e 's,.*package=",,; s,".*,,' | sort -u`
 api=
 for i in $tpackages; do 
  if test -f "rebuilds/$i"; then
    echo "skipping to rebuild $i"
    continue
  fi
  echo "rebuilding $i"
  value="$(perl -MURI::Escape -e 'print uri_escape($ARGV[0]);' "$i")"
  api="$api&package=$value"
  touch "rebuilds/$i"
 done
 if test -n "$api"; then
   osc api -m POST "/build/openSUSE:Factory?cmd=rebuild&repository=standard$api"
 fi
}

osc api /build/openSUSE:Factory/standard/i586/_builddepinfo > /tmp/builddep

touch rebuilds/package-lists-openSUSE
touch rebuilds/antivir-gui
find rebuilds -cmin +1500 -print0 | xargs -0 --no-run-if-empty rm -v

: > /tmp/torebuild
missingdeps=`sed -e 's,.*needed by ,,' /tmp/missingdeps | sort -u`
for i in $missingdeps; do
  maptosource $i >> /tmp/torebuild
done
sort -o /tmp/torebuild -u /tmp/torebuild

split -l 50 /tmp/torebuild rebuilds_
for file in rebuilds_*; do
 rebuildpacs `cat $file`
 rm -f $file
done

