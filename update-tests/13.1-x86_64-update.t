repo @System 0 testtags 13.1-x86_64-system.repo.gz

repo factory 0 solv ../trees/openSUSE:@PROJ@-standard-x86_64.solv
repo nonoss 0 solv ../trees/openSUSE:@PROJ@:NonFree-standard-x86_64.solv

system x86_64 rpm @System

namespace namespace:language(en_US) @SYSTEM
namespace namespace:language(en) @SYSTEM

# DROPS
job distupgrade all packages
