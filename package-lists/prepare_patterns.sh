cd /home/pattern
export RPM_SOURCE_DIR=$PWD
cd products
rm -rf mydata
cp -a patterns-$3-data mydata
cd mydata
export RPM_BUILD_ROOT=/tmp/patterns.$1
export EXPLICIT_UNAME=$2

# call out architecture specifics
for pat in toinstall/rest_*/requires toinstall/rest_*/recommends; do
  sh $RPM_SOURCE_DIR/preprocess $pat > t && mv t $pat
done

# fill up REST-DVD-SUGGESTS
rest_dvd=`grep -l REST-DVD-SUGGESTS toinstall/rest_*/sel | sed -e "s,/sel,,"`
for pat in $rest_dvd; do
  patterns=`cat $pat/requires $pat/recommends 2>/dev/null | sort -u`
  datafiles=`for i in $patterns; do cat toinstall/$i/sel; done  2> /dev/null | sort -u`
  for i in $datafiles; do
    sh $RPM_SOURCE_DIR/preprocess data/$i
  done | perl $RPM_SOURCE_DIR/create-suggests | uniq > data/REST-DVD-SUGGESTS
done

# create dummy roles and summaries
for i in `cd toinstall && ls -1d *`; do 
   mkdir -p utf8_summary/$i/
   echo "=Sum: Nada" >  utf8_summary/$i/default
   mkdir -p utf8_description/$i/ 
   ( echo "+Des:"; echo "nada" ; echo "-Des:" ) >  utf8_description/$i/default
done
cat toinstall/*/role | sort | while read role; do
   mkdir -p utf8_roles/"$role"/
   echo "=Cat: Nada" > utf8_roles/"$role"/default
done

rm -rf $RPM_BUILD_ROOT 
# group together
sh -x $RPM_SOURCE_DIR/sort_patterns 11.2 1 $1 $3
cd ..
rm -rf mydata

