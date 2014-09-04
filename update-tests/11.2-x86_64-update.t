repo @System 0 helix 11.2-x86_64-system.xml.gz
repo factory 0 helix full-x86_64/1-package.xml
repo nonoss 0 helix full-nf-x86_64/1-package.xml
system x86_64 rpm @System
namespace namespace:language(de_DE) @SYSTEM
namespace namespace:language(de) @SYSTEM
namespace namespace:language(de) @SYSTEM
job install name product:openSUSE-fulltree
job erase name amavisd-new
job erase name kernel-default-base
job erase name kernel-debug-base
job erase name kernel-desktop-base
job erase name libsatsolver-devel
job erase name bind-devel
job erase name krb5-mini
job erase name dtc
job erase name krb5-mini-devel
job erase name libdb-4_5-devel
job distupgrade all packages
