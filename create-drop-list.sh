#!/bin/bash
proj="$1"
product="$2"

cd create-drop-list
./create-solv.sh $proj
git add $proj/*.solv
susetags2solv -d MANUAL_OBSOLETES > MANUAL_OBSOLETES.solv
./createdrops.py ../trees/openSUSE:$proj-standard-x86_64.solv \
                 ../trees/openSUSE:$proj:NonFree-standard-x86_64.solv \
		 $proj/*.solv \
                 *.solv > ../osc/openSUSE:$proj/$product/obsoletepackages.inc
cd ../osc/openSUSE:$proj/$product
if [ "$(osc status | wc -l)" -gt 0 ]; then
  osc ci -m "updated drop list"
  # Try to abort a running build - since we change the drop list, openSUSE-release will
  # be rebuilt anyway, invalidating the currently running build of the FTP Tree
  # Also all DVD builds might be invalid, but comapred to the build time of the FTP tree
  # they are negelctable
  echo "Attemptint to abortbuild openSUSE:$proj/000product:openSUSE-ftp-ftp-i586_x86_64/images/local"
  osc abortbuild openSUSE:$proj/000product:openSUSE-ftp-ftp-i586_x86_64/images/local
fi
