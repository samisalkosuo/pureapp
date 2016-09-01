#!/bin/sh


function changeString {
	if [[ $# -ne 3 ]]; then
    	echo "$FUNCNAME ERROR: Wrong number of arguments. Requires FILE FROMSTRING TOSTRING."
    	return 1
	fi

	SED_FILE=$1
	FROMSTRING=$2
	TOSTRING=$3
	TMPFILE=$SED_FILE.tmp

	#escape to and from strings
	FROMSTRINGESC=$(echo $FROMSTRING | sed -e 's/\\/\\\\/g' -e 's/\//\\\//g' -e 's/&/\\\&/g')
	TOSTRINGESC=$(echo $TOSTRING | sed -e 's/\\/\\\\/g' -e 's/\//\\\//g' -e 's/&/\\\&/g')

	sed -e "s/$FROMSTRINGESC/$TOSTRINGESC/g" $SED_FILE  > $TMPFILE && mv $TMPFILE $SED_FILE

	if [ ! -f $TMPFILE ]; then    
	    return 0
 	else
	 	echo "$FUNCNAME ERROR: Something went wrong."
	 	return 2
	fi
}

#setup PureApp Software prereqs as described in
#http://www-01.ibm.com/support/knowledgecenter/SSL5ES_2.1.0/doc/getstart/getstart.dita?lang=en

mkdir /pureapp-sw-data
mkdir /pureapp-sw-runtime

#setup extra disks, if available
#for directories
#/pureapp-sw-data
#/pureapp-sw-runtime
#use fdisk to set up new disks
#follow instruction here http://www.yolinux.com/TUTORIALS/LinuxTutorialAdditionalHardDrive.html
#use following commands to create filesystems (change /dev to correct devices)
#	mkfs.ext4 -L prun /dev/xvdc1
#	mkfs.ext4 -L pdata /dev/xvdc2
#
#mount directories
#	mount -t ext4 /dev/xvdc1 /pureapp-sw-runtime
#	mount -t ext4 /dev/xvdc2 /pureapp-sw-data
#
#add dirs to /etc/fstab
#	echo "/dev/xvdc1            /pureapp-sw-runtime                ext4    defaults        1 2" >> /etc/fstab
#	echo "/dev/xvdc2            /pureapp-sw-data                ext4    defaults        1 2" >> /etc/fstab

#setup extra repo
wget http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
rpm -Uvh epel-release-6*.rpm

#update all packages
#yum -y update

yum -y install compat-libstdc++-33.i686
yum -y install compat-libstdc++-33.x86_64
yum -y install bind-utils.x86_64
yum -y install dhcp.x86_64
yum -y install dnsmasq.x86_64
yum -y install genisoimage.x86_64
yum -y install httpd.x86_64
yum -y install libcgroup.x86_64
yum -y install lsof.x86_64
yum -y install mod_ssl.x86_64
yum -y install mod_security*
#yum -y install mod_security.x86_64
#yum -y install mod_security_crs.noarch
#yum -y install mod_security_crs-extras.noarch
yum -y install ntp.x86_64
yum -y install openssh-clients.x86_64
yum -y install redhat-lsb-core.x86_64
yum -y install unzip.x86_64
yum -y install pam.i686
yum -y install ksh*

#does not setup encrypted disks

mkdir -p /opt/ibm
mkdir -p /data
mkdir -p /home/iwd
mkdir -p /var/log/purescale
mkdir -p /pureapp-sw-runtime/opt/ibm
mkdir -p /pureapp-sw-runtime/data
mkdir -p /pureapp-sw-runtime/home/iwd
mkdir -p /pureapp-sw-runtime/var/log/purescale

mount --bind /pureapp-sw-runtime/opt/ibm /opt/ibm
mount --bind /pureapp-sw-runtime/data /data
mount --bind /pureapp-sw-runtime/home/iwd /home/iwd
mount --bind /pureapp-sw-runtime/var/log/purescale /var/log/purescale

echo "/pureapp-sw-runtime/opt/ibm /opt/ibm none bind 0 0" >> /etc/fstab
echo "/pureapp-sw-runtime/data /data none bind 0 0" >> /etc/fstab
echo "/pureapp-sw-runtime/home/iwd /home/iwd none bind 0 0" >> /etc/fstab
echo "/pureapp-sw-runtime/var/log/purescale /var/log/purescale none bind 0 0" >> /etc/fstab

mkdir -p /data/system
mkdir -p /data/workload
mkdir -p /drouter
mkdir -p /pureapp-sw-data/data/system
mkdir -p /pureapp-sw-data/data/workload
mkdir -p /pureapp-sw-data/drouter

mount --bind /pureapp-sw-data/data/system /data/system
mount --bind /pureapp-sw-data/data/workload /data/workload
mount --bind /pureapp-sw-data/drouter /drouter

echo "/pureapp-sw-data/data/system /data/system none bind 0 0" >> /etc/fstab
echo "/pureapp-sw-data/data/workload /data/workload none bind 0 0" >> /etc/fstab
echo "/pureapp-sw-data/drouter /drouter none bind 0 0" >> /etc/fstab

#disables firewall, better way would be to open ports described in 
#http://www-01.ibm.com/support/knowledgecenter/SSL5ES_2.1.0/doc/getstart/sysreqs.dita?lang=en
#/etc/init.d/iptables stop
#/etc/init.d/iptables save
#chkconfig iptables off

#changeString /etc/selinux/config SELINUX=enforcing SELINUX=disabled
#setenforce 0

#pam.686 may fail
#yum -y install pam.i686
#correct them using similar to:
#cd /var/cache/yum/x86_64/\$releasever/centos/packages/
#and you should find following rpms
#audit-libs-2.3.7-5.el6.i686.rpm  cracklib-2.8.16-4.el6.i686.rpm  db4-4.7.25-19.el6_6.i686.rpm  libselinux-2.0.94-5.8.el6.i686.rpm  pam-1.1.1-20.el6.i686.rpm
#force install them all:
#rpm -Uvh --force *.rpm
#echo "You may restart, if you wish..."
