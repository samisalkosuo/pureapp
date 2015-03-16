# PureApp REST demo
#
#download simplejson from https://github.com/simplejson/simplejson
#and extract to this directory

#no need to use Pure CLI
#execute using: python purerest_demo.py


import sys
import time
import os
import simplejson 
import argparse

parser = argparse.ArgumentParser(description='PureApplication REST functions.')
parser.add_argument('-i','--ip', metavar='ipaddress', type=str, nargs=1,
                   help='PureApp host address',required=True)
parser.add_argument('-u','--uid', metavar='username', type=str, nargs=1,
                   help='PureApp user name',required=True)
parser.add_argument('-p','--pwd', metavar='password', type=str, nargs=1,
                   help='PureApp password',required=True)
parser.add_argument('commands', nargs=argparse.REMAINDER)

args = parser.parse_args()

pureappIPAddress=args.ip[0]
uid=args.uid[0]
password=args.pwd[0]
     

def main():
	for cmd in args.commands:
		func=globals()["%sCMD" % cmd]
		func()


def helpCMD():
	print "Available commands:"
	import types
	for k in globals():
		if k.find("CMD")>-1:
			print k.replace("CMD","")

def sharedsvcCMD():
	path="/resources/sharedServices/"
	json=callREST(path)
	#jsonPrint(json)
	print "Available services:"
	alreadyPrinted=[]
	for svc in json:
		name=svc["app_name"]
		if name not in alreadyPrinted:
			print "  %s" % (name)
			#print "    %s" % (svc["description"])
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
			print "    %s (RAM: %d MB, vCPU: %d) %s" % (instance["displayname"],ram,vcpu,cloudgroup)
		print "    Total: RAM: %.2f GB, vCPU: %d" % (totalram/1000.0,totalcpu)
		totalramforsvc=totalramforsvc+totalram
		totalcpuforsvc=totalcpuforsvc+totalcpu
	print "Totals for shared services:"
	totalramforsvc=totalramforsvc/1000.0
	print "  RAM : %.2f GB" % totalramforsvc
	print "  vCPU: %d" % totalcpuforsvc


def environmentprofilesCMD():
	path="/resources/environmentProfiles"
	json=callREST(path)
	#jsonPrint(json)
	for envProfile in json:
		name=envProfile["name"]
		clouds=envProfile["clouds"]
		cloudgroups=[]
		for cloud in clouds:
			cloudgroups.append(cloud["alias"])
		ramInUse=envProfile["memory_inuse"]
		pcpuInUse=envProfile["pcpu_inuse"]
		vcpuInUse=envProfile["vcpu_inuse"]
		storageInUse=envProfile["storage_inuse"]
		ramCap=envProfile["memory_cap"]
		pcpuCap=envProfile["pcpu_cap"]
		vcpuCap=envProfile["vcpu_cap"]
		storageCap=envProfile["storage_cap"]
		print "%s" % (name)
		print "  Cloud group: %s" % (",".join(cloudgroups))
		print "  Usage      : VCPU: %d/%d PCPU: %d/%d RAM: %.2fGB/%.2fGB Storage: %.2fGB/%.2fGB" % (vcpuInUse,vcpuCap,pcpuInUse,pcpuCap,ramInUse/1000.0,ramCap/1000.0,storageInUse/1000.0,storageCap/1000.0)

#call REST API using curl and return JSON
def callREST(path):
	cmd=["curl","--cacert",pureappIPAddress,"https://%s%s"% (pureappIPAddress,path),"-k","-H",'"X-IBM-PureSystem-API-Version: 1.0"',"-H",'"Accept: application/json"', "--user"," %s:%s" % (uid,password)]
	cmd= " ".join(cmd)
	#print cmd
	fname="output.json"
	rc= os.system(cmd+" > "+fname+" 2> err_output.txt")
	outputfile=open(fname,'r')
	jsonStr=outputfile.read()
	outputfile.close()
	json = simplejson.loads(jsonStr)
	if rc != 0:
		print "some error happened: %d" % rc
	return json

def jsonPrint(json):
	print simplejson.dumps(json, sort_keys=True, indent=2 * ' ')

if __name__ == "__main__": 
	main()
