#!/bin/bash
createsolv()
{
	dir="$1"
	solv="$2"
	output=output
	rm -rf $output
	mkdir -p $output/suse/setup/descr
	wget http://download.opensuse.org/$dir/content -O $output/content
	wget http://download.opensuse.org/$dir/suse/setup/descr/packages.gz -O $output/suse/setup/descr/packages.gz
	susetags2solv -X -c $output/content -d $output/suse/setup/descr/ > "$solv"
	rm -rf $output
}

createsolv "distribution/leap/$1/repo/oss" "$1.repo.oss.solv"
createsolv "distribution/leap/$1/repo/non-oss" "$1.repo.nonoss.solv"

mergesolv $1.repo.oss.solv $1.repo.nonoss.solv > $1.repo.solv
rm $1.repo.oss.solv $1.repo.nonoss.solv
