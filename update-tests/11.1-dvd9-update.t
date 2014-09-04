repo @System 0 helix 11.1-dvd9-system.xml.gz
repo factory 0 helix full-x86_64/1-package.xml
repo nonoss 0 helix full-nf-x86_64/1-package.xml
system x86_64 rpm @System
namespace namespace:language(de_DE) @SYSTEM
namespace namespace:language(de) @SYSTEM
namespace namespace:language(de) @SYSTEM
job install name product:openSUSE-fulltree
job erase name openCryptoki-32bit
job distupgrade all packages
