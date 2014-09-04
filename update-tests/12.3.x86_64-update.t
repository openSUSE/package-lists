repo @System 0 helix 12.3-x86_64-system.xml.gz
repo factory 0 helix full-x86_64/1-package.xml
repo nonoss 0 helix full-nf-x86_64/1-package.xml
system x86_64 rpm @System
namespace namespace:language(de_DE) @SYSTEM
namespace namespace:language(de) @SYSTEM
namespace namespace:language(de) @SYSTEM
job install name product:openSUSE-fulltree
job erase name libdb-4_5-devel
job erase name libdb-4_5-devel-32bit
job erase name libdb_java-4_5
job erase name libdb_java-4_5-devel
job erase name krb5-mini
job erase name krb5-mini-devel
job erase name log4j-mini
job erase name bind-devel
job erase name cloog
job erase name cloog-devel-32bit
job erase name cpufrequtils-devel
job erase name dtc
job erase name ecj-bootstrap
job erase name firebird-classic
job erase name ht
job erase name libreoffice-kde
job erase name libreoffice-kde4
job erase name satsolver-tools-obsolete
job erase name libsatsolver-devel
job erase name libsatsolver-demo
job erase name java-cup-bootstrap
job erase name libelf0-devel
job erase name libotr-devel
job erase name libotr-tools
job erase name espeakedit
job erase name lucene-contrib-db
job erase name python-managesieve
job erase name python3-gobject2-devel
job erase name readline5-devel-32bit
job erase name xmlbeans-mini
job erase name wxWidgets-compat-lib-config
job erase name libwx_gtk2u_html-2_8-0-compat-lib-stl
job erase name libwx_gtk2u_core-2_8-0-compat-lib-stl
job erase name libwx_gtk2u_adv-2_8-0-compat-lib-stl
job erase name libwx_baseu_net-2_8-0-compat-lib-stl
job erase name libwx_baseu-2_8-0-compat-lib-stl
job distupgrade all packages
