repo @System 0 testtags 12.2-i586-system.repo.gz

repo factory 0 solv ../trees/openSUSE:Factory-standard-i586.solv
repo nonoss 0 solv ../trees/openSUSE:Factory:NonFree-standard-i586.solv

system i586 rpm @System

namespace namespace:language(de_DE) @SYSTEM
namespace namespace:language(de) @SYSTEM

job erase name libdb-4_5-devel
job erase name krb5-mini
job erase name krb5-mini-devel
job erase name libreoffice-kde4

# DROPS
job distupgrade all packages
