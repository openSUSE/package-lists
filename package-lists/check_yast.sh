# check if our copy is valid
curl -s 'http://svn.opensuse.org/viewcvs/yast/trunk/extra-packages?view=co' > yast_packs.rec

ret=0
archs=$2
test -n "$archs" || archs="__x86_64__ __i386__ __ppc__ __ppc64__"

# __ia64__ __s390__ __s390x__
(
for i in $archs; do
  cpp -E -Ulinux -D$i yast_packs.rec  | grep -v '^#' | grep -v '^ '
done
) | sort -u | sed -e "s,:, ," > yast.list
cat yast.list | while read yast pack; do
  if grep -qx "$yast" $1; then
     if ! grep -qx "$pack" $1; then
        echo "Yast module $yast needs $pack"
        ret=1
     fi
  fi
done

exit $ret

