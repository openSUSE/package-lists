for i in *.xml.in; do 
echo $i
./update.sh $i > $i.update
if test ! -s $i.update; then
  grep -C3 === $i.output
  : > $i.remove
  continue
fi

sed -e 's,delete_unmaintained="false",delete_unmaintained="true",' $i > ${i/update.xml.in/remove.xml}
./update.sh ${i/update.xml.in/remove.xml} > $i.remove
diff -u $i.update $i.remove | grep '^[-+]'
done
