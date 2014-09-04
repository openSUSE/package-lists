repo @System 0 helix 12.3-i586-system.xml.gz
repo factory 0 helix full-i586/1-package.xml
repo nonoss 0 helix full-nf-i586/1-package.xml
system i586 rpm @System
namespace namespace:language(de_DE) @SYSTEM
namespace namespace:language(de) @SYSTEM
namespace namespace:language(de) @SYSTEM
job install name product:openSUSE-fulltree
job erase name libdb-4_5-devel
job erase name krb5-mini
job erase name krb5-mini-devel
job erase name log4j-mini
job erase name libibus-1_0-0
job distupgrade all packages
