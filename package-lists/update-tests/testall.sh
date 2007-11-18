for i in *.xml.in; do 
echo $i
./update.sh $i > list.update
sed -e 's,delete_unmaintained="false",delete_unmaintained="true",' $i > ${i/update.xml.in/remove.xml}
./update.sh ${i/update.xml.in/remove.xml} > list.remove
diff -u list.update list.remove | grep '^[-+]'
done
