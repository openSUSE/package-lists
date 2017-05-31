#!/bin/bash
set -e
proj="${1:-Factory}"

case "$proj" in
        Factory)
		dir="tumbleweed"
		;;
        Leap:42.3)
                dir="distribution/leap/42.3"
		;;
	*)
		exit 0
		;;
esac


createsolv()
{
	repopath="$1"
	solv="$2"
	output=output
	rm -rf $output
	mkdir -p $output/suse/setup/descr
	curl -s -f http://download.opensuse.org/$repopath/content -o $output/content
	curl -s -f http://download.opensuse.org/$repopath/suse/setup/descr/packages.gz -o $output/suse/setup/descr/packages.gz
	susetags2solv -X -c $output/content -d $output/suse/setup/descr/ > "$solv"
	rm -rf $output
}

b=`curl -s -f http://download.opensuse.org/$dir/repo/oss/media.1/build`
b="${b//[^[:alnum:]]/_}"
out="$proj/$b.repo.solv"
if [ -e "$out" ]; then
	echo "$out exists"
	exit 0
fi

createsolv "$dir/repo/oss" "${b}.repo.oss.solv"
createsolv "$dir/repo/non-oss" "${b}.repo.nonoss.solv"

mergesolv $b.repo.oss.solv $b.repo.nonoss.solv > $out
rm $b.repo.oss.solv $b.repo.nonoss.solv
