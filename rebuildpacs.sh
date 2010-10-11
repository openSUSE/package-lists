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
 api='/build/openSUSE:Factory?cmd=rebuild&repository=standard'
 for i in $tpackages; do 
  echo "rebuilding $i"
  value="$(perl -MURI::Escape -e 'print uri_escape($ARGV[0]);' "$i")"
  api="$api&package=$value"
 done
 #osc api -m POST $api
}

osc api /build/openSUSE:Factory/standard/i586/_builddepinfo > /tmp/builddep

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

