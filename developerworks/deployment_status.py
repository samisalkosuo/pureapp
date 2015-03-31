import sys
import time
import os

if len(sys.argv)==2:
  #read virtual instance id from command line
  virtualInstanceID=sys.argv[1]
else:
  #read id from a file
  f=open("virtualInstanceID","r")
  virtualInstanceID=f.read().strip()
  f.close()
#get instance
instances=deployer.virtualsysteminstances.list({'id':virtualInstanceID})
if len(instances)==0:
  print "Instance %s does not exist." % (virtualInstanceID)
else:
  instance=instances[0]
  #print deployment history
  history=instance.history
  for line in history:
    print "%s: %s" % (line['created_time'],line['current_message'])
  name=instance.deployment_name
  status=instance.status
  print 'Instance "%s"... %s' % (name,status)
  if status=="RUNNING":
    #list virtual machines
    print 'Virtual machines:'
    virtualmachines=instance.virtualmachines
    for vm in virtualmachines:
      name=vm.displayname
      ip=vm.ip
      hostname=ip.userhostname
      ipaddr=ip.ipaddress
      print "  %s (%s): %s" % (hostname,ipaddr,name)
