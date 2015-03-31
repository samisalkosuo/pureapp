import sys
import time
import os

if len(sys.argv)!=3:
  print "Usage: %s <pattern name> <environment profile name>"
  exit(1)

#pattern name and env profile name as arguments
patternName=sys.argv[1] 
envProfileName=sys.argv[2] 
ctime=time.strftime("%H%M%S")
print "Deploying pattern '%s' to profile '%s'..." %  \
  (patternName,envProfileName)
#retrieve pattern and environment profile objects from PureApplication
#based on given names
mypattern=deployer.virtualsystempatterns.list({"app_name": patternName})[0]
envprofile=deployer.environmentprofiles.list({'name':envProfileName})[0]
deploymentParams={
  'environment_profile':envprofile
}
#initiate deployment
virtualInstance=mypattern.deploy("%s %s" % 
                                (patternName,ctime),deploymentParams)
#get instance ID
virtualInstanceID=virtualInstance.id 
#print out ID and save ID to a file, for later use
print "Pattern %s is deploying. ID: %s" % (patternName,virtualInstanceID)
f=open("virtualInstanceID","w")
f.write(virtualInstanceID)
f.close()
