#!/bin/sh

#This scripts configures Linux for Oracle 12c
echo "Configure Linux for Oracle 12c..."

#directories, assuming these exist
SCRIPTDIR=$(pwd)
ORACLE_INSTALL_FILES=/u01/install_files


#confgure SELINUX if needed
SELINUX_CFG=/etc/selinux/config
cat $SELINUX_CFG  |grep "SELINUX=enforcing" > /dev/null
if [[ $? -eq 0 ]] ; then
	sed -e 's/SELINUX=enforcing/SELINUX=permissive/g' $SELINUX_CFG  > $SELINUX_CFG.tmp && mv $SELINUX_CFG.tmp $SELINUX_CFG    
	#Set SELINUX to Permissive in this session
	setenforce 0
fi

#install Oracle prereq RPM
#this one adds oracle-user and configure kernel values and such
cd /etc/yum.repos.d
wget --no-check-certificate https://public-yum.oracle.com/public-yum-ol6.repo
wget --no-check-certificate https://public-yum.oracle.com/RPM-GPG-KEY-oracle-ol6 -O /etc/pki/rpm-gpg/RPM-GPG-KEY-oracle
yum -y install oracle-rdbms-server-12cR1-preinstall
cd $SCRIPTDIR

#unzip database files
cd $ORACLE_INSTALL_FILES
unzip linuxamd64_12102_database_1of2.zip
unzip linuxamd64_12102_database_2of2.zip
cd $SCRIPTDIR

echo "Linux configured."
