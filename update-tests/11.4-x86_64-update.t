repo @System 0 testtags 11.4-x86_64-system.repo.gz

repo factory 0 solv ../trees/openSUSE:@PROJ@-standard-x86_64.solv
repo nonoss 0 solv ../trees/openSUSE:@PROJ@:NonFree-standard-x86_64.solv

system x86_64 rpm @System

namespace namespace:language(de_DE) @SYSTEM
namespace namespace:language(de) @SYSTEM

job erase name kernel-default-base
job erase name kernel-debug-base
job erase name kernel-trace-base
job erase name kernel-ec2-base
job erase name kernel-xen-base
job erase name kernel-desktop-base
job erase name aspell-mr
job erase name nagios-plugins-extras
job erase name libsatsolver-devel
job erase name bind-devel
job erase name krb5-mini
job erase name dtc
job erase name krb5-mini-devel
job erase name libdb-4_5-devel
job erase name ecj-bootstrap
job erase name xmlbeans-mini
job erase name java-cup-bootstrap
job erase name libreoffice-kde4
job erase name log4j-mini
job erase name libdb_java-4_5
job erase name libdb_java-4_5-devel
job erase name lucene-contrib-db
job erase name python-managesieve

# DROPS
job distupgrade all packages
