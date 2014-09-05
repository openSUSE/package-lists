mkdir -p $1/suse/setup/descr
wget http://download.opensuse.org/distribution/$1/repo/oss/content -O $1/content
wget http://download.opensuse.org/distribution/$1/repo/oss/suse/setup/descr/packages.gz -O $1/suse/setup/descr/packages.gz
susetags2solv -X -c $1/content -d $1/suse/setup/descr/ > $1.repo.solv
rm -rf $1
