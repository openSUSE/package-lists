repo @System 0 testtags 12.1-i586-system.repo.gz
repo factory 0 solv ../trees/openSUSE:@PROJ@-standard-i586.solv
repo nonoss 0 solv ../trees/openSUSE:@PROJ@:NonFree-standard-i586.solv

system i586 rpm @System

namespace namespace:language(de_DE) @SYSTEM
namespace namespace:language(de) @SYSTEM

# DROPS

job erase name krb5-mini
job erase name krb5-mini-devel
job erase name libdb-4_5-devel
job erase name log4j-mini

job distupgrade all packages
