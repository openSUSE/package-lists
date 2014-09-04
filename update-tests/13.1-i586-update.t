repo @System 0 testtags 13.1-i586-system.repo.gz

repo factory 0 solv ../trees/openSUSE:Factory-standard-i586.solv
repo nonoss 0 solv ../trees/openSUSE:Factory:NonFree-standard-i586.solv

system i586 rpm @System

namespace namespace:language(en_US) @SYSTEM
namespace namespace:language(en) @SYSTEM

# DROPS
job distupgrade all packages
