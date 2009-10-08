c=0 
for i in `cat $1 `; do 
   list=`ls -1 testtrack/full-head-$2/susex/*/$i.rpm 2> /dev/null | head -n 1`
   if test -f "$list"; then
      s=`stat -c %s $list`
   else
      s=0
   fi
   c=$(($c+$s)); 
done
echo $1 $(($c/1048576))


