# check if our copy is valid
curl -s 'http://svn.opensuse.org/viewcvs/yast/trunk/extra-packages?view=co' > yast_packs.new
diff -u yast_packs yast_packs.new || exit 1
rm yast_packs.new

# __ia64__ __s390__ __s390x__
(
for i in __x86_64__ __i386__ __ppc__ __ppc64__; do
  cpp -E -Ulinux -D$i yast_packs.rec  | grep -v '^#' | grep -v '^ '
done
) | sort -u | sed -e "s,:, ," > yast.list
cat yast.list | while read yast pack; do
  if grep -qx "$yast" $1; then
     grep -qx "$pack" $1 || echo "Yast module $yast needs $pack"
  fi
done
