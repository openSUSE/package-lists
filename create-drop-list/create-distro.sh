mkdir -p $1/suse/setup/descr
wget http://download.opensuse.org/distribution/$1/repo/oss/content -O $1/content
wget http://download.opensuse.org/distribution/$1/repo/oss/suse/setup/descr/packages.gz -O $1/suse/setup/descr/packages.gz
susetags2solv -X -c $1/content -d $1/suse/setup/descr/ > $1.repo.oss.solv
rm -rf $1
mkdir -p $1/suse/setup/descr

wget http://download.opensuse.org/distribution/$1/repo/non-oss/content -O $1/content
wget http://download.opensuse.org/distribution/$1/repo/non-oss/suse/setup/descr/packages.gz -O $1/suse/setup/descr/packages.gz
susetags2solv -X -c $1/content -d $1/suse/setup/descr/ > $1.repo.nonoss.solv

rm -rf $1

mergesolv $1.repo.oss.solv $1.repo.nonoss.solv > $1.repo.solv
rm $1.repo.oss.solv $1.repo.nonoss.solv
