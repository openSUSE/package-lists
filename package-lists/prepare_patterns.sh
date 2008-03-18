cd /home/pattern
export RPM_SOURCE_DIR=$PWD
cd products/patterns-openSUSE-data
for i in `cd toinstall && ls -1d *`; do 
   mkdir -p utf8_summary/$i/
   echo "=Sum: Nada" >  utf8_summary/$i/default
   mkdir -p utf8_description/$i/ 
   ( echo "+Des:"; echo "nada" ; echo "-Des:" ) >  utf8_description/$i/default
done
rm -rf /tmp/patterns
export RPM_BUILD_ROOT=/tmp/patterns.$1
export EXPLICIT_UNAME=$1
sh -x $RPM_SOURCE_DIR/sort_opensuse_patterns 11.0 1 $1

