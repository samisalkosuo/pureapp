echo "Installing UCD..."


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

cho "Downloading UCD binaries..."


wget $UCDSERVER_BINARY_URL

echo "Extracting UCD binary..."
unzip -q *.zip
echo "Extracting UCD binary... done."

echo "Move ucd install dir under /...."
mv ibm-ucd-install /



INSTALL_DIR=/ibm-ucd-install

cd $INSTALL_DIR

#modify install properties file
INSTALL_PROPS=install.properties

PASSWORD=$UCD_SERVER_ADMIN_PASSWORD

echo nonInteractive=true >> $INSTALL_PROPS 
echo server.initial.password=$PASSWORD >> $INSTALL_PROPS
echo hibernate.connection.password >> $INSTALL_PROPS

./install-server.sh

echo "UCD server installed."

echo "Setting auto start..."
#as instructed in http://www.ibm.com/support/knowledgecenter/en/SS4GSP_6.2.1/com.ibm.udeploy.install.doc/topics/run_server.html

chmod ugo+x /etc/rc.d/init.d/functions

SVC_FILE=/opt/ibm-ucd/server/bin/init/server

changeString $SVC_FILE @SERVER_USER@ root
changeString $SVC_FILE @SERVER_GROUP@ root

#change flags after changing the file, above commands create new file and resets flags
chmod 755 $SVC_FILE

cd /etc/init.d
ln -s /opt/ibm-ucd/server/bin/init/server ucdserver

chkconfig --add ucdserver
chkconfig ucdserver on
service ucdserver start

echo "UCD server started."

 



