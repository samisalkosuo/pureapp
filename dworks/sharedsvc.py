import sys
import time
import os
import simplejson 

if len(sys.argv)!=4:
  print "Usage: %s <ip address> <uid> <pwd>" % sys.argv[0]
  exit(1)

pureappIPAddress=sys.argv[1]
uid=sys.argv[2]
password=sys.argv[3]

#call REST API using curl and return JSON
def callREST(path):
  cmd=["curl","--cacert",pureappIPAddress,"https://%s%s" %
     (pureappIPAddress,path),  
     "-k","-H",'"X-IBM-PureSystem-API-Version: 1.0"',
     "-H",'"Accept: application/json"', "--user"," %s:%s" % (uid,password)]
  cmd= " ".join(cmd)
  fname="output.json"
  rc= os.system(cmd+" > "+fname+" 2> err_output.txt")
  outputfile=open(fname,'r')
  jsonStr=outputfile.read()
  outputfile.close()
  json = simplejson.loads(jsonStr)
  if rc != 0:
    print "some error happened: %d" % rc
  return json

path="/resources/sharedServices/"
json=callREST(path)
print "Available services:"
alreadyPrinted=[]
for svc in json:
  name=svc["app_name"]
  if name not in alreadyPrinted:
    print "  %s" % (name)
    alreadyPrinted.append(name)
path="/resources/sharedServiceInstances/"
json=callREST(path)
print "Deployments:"
totalramforsvc=0
totalcpuforsvc=0
for svc in json:
  print "  Name: %s" % svc["deployment_name"]
  totalram=0
  totalcpu=0
  for instance in svc["instances"]:
    ram=instance["memory"]
    totalram=totalram+ram
    vcpu=instance["cpucount"]
    totalcpu=totalcpu+vcpu
    cloudgroup=instance["location"]["cloud_group"]["name"]
    print "    %s (RAM: %d MB, vCPU: %d) %s" % 
          (instance["displayname"],ram,vcpu,cloudgroup)
  print "    Total: RAM: %.2f GB, vCPU: %d" % (totalram/1000.0,totalcpu)
  totalramforsvc=totalramforsvc+totalram
  totalcpuforsvc=totalcpuforsvc+totalcpu
print "Totals for shared services:"
totalramforsvc=totalramforsvc/1000.0
print "  RAM : %.2f GB" % totalramforsvc
print "  vCPU: %d" % totalcpuforsvc
