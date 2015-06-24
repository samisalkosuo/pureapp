echo Deploying i2 IAP 3.0.11 example deployment

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


SCRIPTDIR=$(pwd)

export IAPBINARYFILE=I2_INT_ANA_PLTF_V3.0.11_MP_ML.zip
export INSTALLDIR=/iap/install/
export IAPREPOSITORY=/iap/install/iap-repository
export IAPDIR=/iap/3011
export IAPDEPLOYMENTTOOLKITDIR=$IAPDIR/IAP-Deployment-Toolkit

#get and unzip IAP 3.0.11 from file server
wget -q http://$FILESERVER_IP/$IAPBINARYFILE
mkdir -p $INSTALLDIR
mv $IAPBINARYFILE $INSTALLDIR
cd $INSTALLDIR
unzip $IAPBINARYFILE

#install Installation Manager that's included in IAP
cd $INSTALLDIR/installation-manager
unzip -q agent.installer.linux.gtk.x86_64_1.8.0.20140902_1503.zip
./installc -acceptLicense

#make IAP install dirs and bindmount them to
#another location, because default Linux image has limited space 
#and with bind mount there's no need add additional disks
mkdir -p /opt/IBM/iap
mkdir -p /iap/3011
mount --bind /iap/3011 /opt/IBM/iap

#generate response file
/opt/IBM/InstallationManager/eclipse/tools/imcl  -repositories $IAPREPOSITORY generateResponseFile > response.xml
#change install dir
changeString response.xml /opt/IBM/iap $IAPDIR  

#add HOMEDRIVE env variable, because otherwise IM response file install fails
export HOMEDRIVE=/root
/opt/IBM/InstallationManager/eclipse/tools/imcl -acceptLicense input response.xml
echo IAP deployment toolkit installed in $IAPDIR

#copy example configuration
cp -r $IAPDEPLOYMENTTOOLKITDIR/configuration-example $IAPDEPLOYMENTTOOLKITDIR/configuration
#generate IAP defaults
cd $IAPDEPLOYMENTTOOLKITDIR/scripts
./setup -t generateDefaults

#modify configuration/environment/http-server.properties
changeString $IAPDEPLOYMENTTOOLKITDIR/configuration/environment/http-server.properties http.server.home.dir=/opt/IBM/HTTPServer http.server.home.dir=/opt/IBM/WebSphere/HTTPServer
#nodify configuration/environment/iap/environment.properties
changeString $IAPDEPLOYMENTTOOLKITDIR/configuration/environment/iap/environment.properties db.database.location.dir.db2=/home/db2inst1 db.database.location.dir.db2=/db2inst1 

#copy db2jcc4.jar to IAP deployment toolkit
cp /opt/ibm/db2/V10.5/java/db2jcc4.jar $IAPDEPLOYMENTTOOLKITDIR/configuration/environment/common/jdbc-drivers/

#set up credentials
CREDENTIALSFILE=$IAPDEPLOYMENTTOOLKITDIR/configuration/environment/credentials.properties
echo db.write1.user-name=$DBUSERNAME > $CREDENTIALSFILE 
echo db.write1.password=$DBUSERPASSWORD >> $CREDENTIALSFILE

#set root in dbadmin group, otherwise IAP deployment fails
usermod -a -G db2iadm1 root 

#deploy IAP
./setup -t deployExample

#start Liberty
./setup -t startLiberty

#restart HTTP Server
/opt/IBM/WebSphere/HTTPServer/bin/apachectl -k restart

echo i2 IAP example deployment done 
