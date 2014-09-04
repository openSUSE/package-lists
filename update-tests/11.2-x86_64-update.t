repo @System 0 testtags 11.2-x86_64-system.repo.gz

repo factory 0 solv ../trees/openSUSE:Factory-standard-x86_64.solv
repo nonoss 0 solv ../trees/openSUSE:Factory:NonFree-standard-x86_64.solv

system x86_64 rpm @System

namespace namespace:language(de_DE) @SYSTEM
namespace namespace:language(de) @SYSTEM

# DROPS
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
