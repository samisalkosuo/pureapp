#!/bin/sh

#set up Oracle database
if [[ "$1" != "" ]] ; then
	DEFAULT_PWD=$1
	echo "Using user specified default password"
else
	DEFAULT_PWD=passW0RD 
fi
ORCL_USR=oracle
ORCL_GRP=oinstall
ORCL_USR_GRP=$ORCL_USR:$ORCL_GRP
ORCL_HOME_DIR=/home/$ORCL_USR


#add user to database
echo "Add user '$ORCL_USR' to database..."
ORCL_DB_USR=$ORCL_USR
SQLFILE=$ORCL_HOME_DIR/createuser.txt
echo "CONNECT sys/$DEFAULT_PWD as sysdba;" >> $SQLFILE
echo "CREATE USER $ORCL_DB_USR IDENTIFIED BY $DEFAULT_PWD;" >> $SQLFILE
echo "GRANT CONNECT TO $ORCL_DB_USR;" >> $SQLFILE
echo "GRANT RESOURCE TO $ORCL_DB_USR;" >> $SQLFILE
echo "GRANT CREATE VIEW TO $ORCL_DB_USR;" >> $SQLFILE
echo "DISCONNECT;" >> $SQLFILE
echo "QUIT;" >> $SQLFILE
chown $ORCL_USR_GRP $SQLFILE
su - oracle -c "cat $SQLFILE | sqlplus /nolog" > sql.log
echo "Add user '$ORCL_USR' to database...done."
