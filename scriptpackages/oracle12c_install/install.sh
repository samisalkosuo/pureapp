#!/bin/sh
#this script installs Oracle 12c database
#assumes unzipped Oracle 12c installfiles in dir /u01/install_files/database
#and Linux configured as per Oracle installation guide
#see script prereq.sh

echo "Silent Service: installing Oracle..."

if [[ "$1" != "" ]] ; then
	DEFAULT_PWD=$1
	echo "Using user specified default password"
else
	DEFAULT_PWD=passW0RD 
fi
SCRIPTDIR=$(pwd)
ORACLE_INSTALL_FILES=/u01/install_files

HOSTNAME=$(hostname -s)
DOMAINNAME=$(hostname -d)

ORCL_USR=oracle
ORCL_GRP=oinstall
ORCL_USR_GRP=$ORCL_USR:$ORCL_GRP
ORCL_HOME_DIR=/home/$ORCL_USR
ORCL_PORT=1521
ORCL_SID=orcl12c
ORCL_IGNORE_PREREQ=0

#change owner of /u01 directory
chown -R $ORCL_USR_GRP /u01
chmod -R 775 /u01

#set up oracle password
echo $DEFAULT_PWD | passwd --stdin $ORCL_USR > /dev/null

#modify default install response file
RESPONSE_FILE=db.rsp
sed -e "s/%HOSTNAME%/$HOSTNAME/g" $RESPONSE_FILE  > $RESPONSE_FILE.tmp && mv $RESPONSE_FILE.tmp $RESPONSE_FILE

cp $RESPONSE_FILE $ORCL_HOME_DIR/$RESPONSE_FILE
chown $ORCL_USR_GRP $ORCL_HOME_DIR/$RESPONSE_FILE

#install oracle silently using response file
if [[ $ORCL_IGNORE_PREREQ -eq 0 ]] ; then
	su - $ORCL_USR -c "cd $ORACLE_INSTALL_FILES/database;./runInstaller -silent -ignorePrereq -responseFile $ORCL_HOME_DIR/$RESPONSE_FILE" > runinstaller.log
else
	su - $ORCL_USR -c "cd $ORACLE_INSTALL_FILES/database;./runInstaller -silent -responseFile $ORCL_HOME_DIR/$RESPONSE_FILE" > runinstaller.log
fi

#wait until log dir exists
echo "Wait until log dir exists..."
ls -t /u01/app/oraInventory/logs &> /dev/null
while [[ $? -ne 0 ]] ; do
    ls -t /u01/app/oraInventory/logs &> /dev/null
done
LOGDIR=$(ls -t /u01/app/oraInventory/logs)
echo "Wait until log dir exists...done"

#wait until log dir is not empty
echo "Wait until log dir is not empty..."
while [[ -z $LOGDIR ]] ; do
    LOGDIR=$(ls -t /u01/app/oraInventory/logs)
done
echo "Wait until log dir is not empty...done"

LOGFILE=$(echo /u01/app/oraInventory/logs/$(ls -t /u01/app/oraInventory/logs | head -n 1))
echo "Waiting for Oracle installer to finish in background...."
echo "See log file $LOGFILE"
SHUTDOWN_TXT="Shutdown Oracle Database 12c Release 1 Installer"
grep -q "$SHUTDOWN_TXT" $LOGFILE
while [[ $? -ne 0 ]] ; do
	grep -q "$SHUTDOWN_TXT" $LOGFILE
done

echo "Executing oracle root scripts"
/u01/app/oraInventory/orainstRoot.sh
/u01/app/oracle/product/12.1.0/dbhome_1/root.sh
echo "Oracle is now installed"

echo "Set up environment variables for user oracle"

echo "#Oracle settings" >> $ORCL_HOME_DIR/.bash_profile
echo "export ORACLE_BASE=/u01/app/oracle" >> $ORCL_HOME_DIR/.bash_profile
echo "export ORACLE_SID=$ORCL_SID" >> $ORCL_HOME_DIR/.bash_profile
echo "export ORACLE_HOME=/u01/app/oracle/product/12.1.0/dbhome_1" >> $ORCL_HOME_DIR/.bash_profile
echo "export PATH=\$ORACLE_HOME/bin:\$PATH" >> $ORCL_HOME_DIR/.bash_profile
chown $ORCL_USR_GRP $ORCL_HOME_DIR/.bash_profile

#create database
echo "Creating oracle database"
RESPONSE_FILE=dbca.rsp
#GDBNAME=$HOSTNAME.$DOMAINNAME
GDBNAME=$ORCL_SID
sed -e "s/%GDBNAME%/$GDBNAME/g" $RESPONSE_FILE  > $RESPONSE_FILE.tmp && mv $RESPONSE_FILE.tmp $RESPONSE_FILE
sed -e "s/%PWD%/$DEFAULT_PWD/g" $RESPONSE_FILE  > $RESPONSE_FILE.tmp && mv $RESPONSE_FILE.tmp $RESPONSE_FILE
sed -e "s/%SID%/$ORCL_SID/g" $RESPONSE_FILE  > $RESPONSE_FILE.tmp && mv $RESPONSE_FILE.tmp $RESPONSE_FILE
cp $RESPONSE_FILE $ORCL_HOME_DIR/$RESPONSE_FILE
chown $ORCL_USR_GRP $ORCL_HOME_DIR/$RESPONSE_FILE
su - $ORCL_USR -c "dbca -silent -responseFile $ORCL_HOME_DIR/$RESPONSE_FILE"

#create network listener
echo "Creating network listener"
RESPONSE_FILE=netca.rsp
sed -e "s/%PORT%/$ORCL_PORT/g" $RESPONSE_FILE  > $RESPONSE_FILE.tmp && mv $RESPONSE_FILE.tmp $RESPONSE_FILE
cp $RESPONSE_FILE $ORCL_HOME_DIR/$RESPONSE_FILE
chown $ORCL_USR_GRP $ORCL_HOME_DIR/$RESPONSE_FILE
su - $ORCL_USR -c "export DISPLAY=$HOSTNAME:0.0;netca -silent -responseFile $ORCL_HOME_DIR/$RESPONSE_FILE"

#Open firewall for Oracle
echo "Configuring firewall..."
iptables -I INPUT 1 -p tcp -m tcp --dport $ORCL_PORT -j ACCEPT 
iptables -I INPUT 1 -p tcp -m tcp --sport $ORCL_PORT -j ACCEPT 
iptables -I OUTPUT 1 -p tcp -m tcp --sport $ORCL_PORT -j ACCEPT
iptables -I OUTPUT 1 -p tcp -m tcp --dport $ORCL_PORT -j ACCEPT
#save firewall rules
/sbin/service iptables save 
/sbin/service iptables restart

echo "Silent Service: installing Oracle... done."
