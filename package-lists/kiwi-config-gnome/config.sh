#!/bin/bash
#================
# FILE          : config.sh
#----------------
# PROJECT       : OpenSuSE KIWI Image System
# COPYRIGHT     : (c) 2006 SUSE LINUX Products GmbH. All rights reserved
#               :
# AUTHOR        : Marcus Schaefer <ms@suse.de>
#               :
# BELONGS TO    : Operating System images
#               :
# DESCRIPTION   : configuration script for SUSE based
#               : operating systems
#               :
#               :
# STATUS        : BETA
#----------------
#======================================
# Functions...
#--------------------------------------
test -f /.kconfig && . /.kconfig
test -f /.profile && . /.profile

#======================================
# Greeting...
#--------------------------------------
echo "Configure image: [$name]..."

#======================================
# Activate services
#--------------------------------------
suseActivateServices
suseRemoveService boot.multipath
suseRemoveService boot.device-mapper
suseRemoveService mdadmd
suseRemoveService multipathd
suseRemoveService rpmconfigcheck
suseRemoveService waitfornm
suseRemoveService smb
suseRemoveService xfs
suseRemoveService nmb
suseRemoveService autofs
suseRemoveService rpasswdd
suseRemoveService boot.scsidev
suseRemoveService boot.md
suseRemoveService earlygdm
suseInsertService create_xconf

rm -f /etc/init.d/earlygdm

cd /
patch -p0 < /tmp/config.patch
rm /tmp/config.patch

insserv 

rpm -e smart
rpm -e rpm-python
rpm -e python

#======================================
# SuSEconfig
#--------------------------------------
suseConfig

#======================================
# Umount kernel filesystems
#--------------------------------------
baseCleanMount

exit 0
