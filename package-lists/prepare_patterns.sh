cd /home/pattern
svn up
export RPM_SOURCE_DIR=$PWD
cd products/patterns-openSUSE-data
for i in `cd toinstall && ls -1d *`; do mkdir -p utf8_summary/$i/; echo "=Sum: Nada" >  utf8_summary/$i/default; mkdir -p utf8_description/$i/; echo "+Des:" >  utf8_description/$i/default; echo "nada" >> utf8_description/$i/default; echo "-Des:" >>  utf8_description/$i/default; done
rm -rf /tmp/patterns
export RPM_BUILD_ROOT=/tmp/patterns
export EXPLICIT_UNAME=i586
sh -x $RPM_SOURCE_DIR/sort_opensuse_patterns 11.0 1 i586

