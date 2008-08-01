c=0 
for i in `cat $1 `; do 
   s=`stat -c %s testtrack/full-$2/susex/*/$i.rpm | head -n 1`; 
   c=$(($c+$s)); 
done
echo $1 $c

