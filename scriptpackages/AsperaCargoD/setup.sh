#setup Aspera CargoD

#download package
#install cargod
#setup config file
#execute: /opt/aspera/cargod/bin/asperacargod &

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



/sbin/service iptables stop

if [[ "$CARGOD_RPM_URL" == "" ]] ; then
  CARGOD_RPM_URL="http://download.asperasoft.com/download/sw/cargodownloader/1.3/aspera-cargod-1.3.0.80012-linux-32.rpm"
fi 

wget $CARGOD_RPM_URL

#prereqs:
yum -y install glibc.i686
yum -y install zlib-devel.i686

rpm -i aspera-cargod-1.3.0.80012-linux-32.rpm

cp asperacargo.conf.template asperacargo.conf


if [[ "$FASPEXUSER" == "" ]] ; then
  echo "Enter Faspex username: "
  read FASPEXUSER
fi 

if [[ "$FASPEXPASSWORD" == "" ]] ; then
  echo "Enter Faspex password: "
  read FASPEXPASSWORD
fi 

if [[ "$FASPEXURL" == "" ]] ; then
  echo "Enter Faspex URL: "
  read FASPEXURL
fi 

if [[ "$DOWNLOADDIR" == "" ]] ; then
  echo "Enter download directory: "
  read DOWNLOADDIR
fi 


changeString asperacargo.conf %USER% $FASPEXUSER
changeString asperacargo.conf %PASSWORD% $FASPEXPASSWORD
changeString asperacargo.conf %FASPEXURL% $FASPEXURL
changeString asperacargo.conf %DOWNLOADDIR% $DOWNLOADDIR

mv asperacargo.conf /opt/aspera/cargod/etc/asperacargo.conf

#comment if not want to start automatically
/opt/aspera/cargod/bin/asperacargod &

echo "View transfers..."
echo "use cmd: tail -f /opt/aspera/cargod/bin/../var/log/asperacargod.log"