#!/bin/sh

mv sles-common.xml sles-common.xml.in
mv solver-system.xml solver-system.xml.in
rm -f *.error *.output *.xml *~
mv sles-common.xml.in sles-common.xml
mv solver-system.xml.in solver-system.xml
