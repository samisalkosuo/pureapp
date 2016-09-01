
UCD_SERVER_URL="https://$UCD_SERVER_IP:8443"



#install UCD CLI toolkit
CMD="wget --no-check-certificate $UCD_SERVER_URL/tools/udclient.zip"
#try to download 5 times before giving up
n=0
until [ $n -ge 5 ]
do
   $CMD && break  
   echo "Download failed.. trying again..."
   n=$[$n+1]
   sleep 15
done
   
   
unzip udclient.zip

mv udclient $UDCLIENT_DIR


if [[ "$EXECUTE_DEFAULT_UCD_CONFIG" == "true" ]] ; then
  
  	#add default agent
  	FILE=json.txt
 	echo "{" > $FILE
 	echo "\"artifactAgent\" : \"$UCD_DEFAULT_AGENT_NAME\"" >>  $FILE
	echo "}" >> $FILE		  
  
	$UDCLIENT_DIR/udclient -username $UCD_ADMIN_USER -password $UCD_ADMIN_PASSWORD -weburl $UCD_SERVER_URL setSystemConfiguration $FILE
  
fi 

