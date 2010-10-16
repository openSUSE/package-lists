cd testtrack
bash ./update_full.sh power-ppc
cd ..

osc api '/build/openSUSE:Factory:PowerPC/_result?package=bash&repository=standard' > /tmp/state
if grep -q 'dirty="true"' /tmp/state || grep -q 'state="building"' /tmp/state; then
  echo "standard still dirty"
  exit 0
fi

pushd testtrack
WITHDESCR=1 bash ./update_full.sh power-ppc || touch ../dirty
cd ..
if test -f dirty; then
  popd
  installcheck ppc testtrack/full-power-ppc/suse/setup/descr/packages | grep "nothing provides"  | sed -e 's,-[^-]*-[^-]*$,,' | sort -u > /tmp/missingdeps_ppc
  ./rebuildpacs.sh ppc
  rm -f dirty
fi

