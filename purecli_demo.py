# PureApp CLI demo
#
import sys
import time
import os

cmd=sys.argv[1] 

def main():
	func=globals()["%sCMD" % cmd]
	func()


def helpCMD():
	print "Available commands:"
	import types
	for k in globals():
		if k.find("CMD")>-1:
			print k.replace("CMD","")

def cloudgroupsCMD():
	for cloudgroup in admin.clouds:
		print "%s:" % cloudgroup.name
		for node in cloudgroup.computenodes:
			u=node.physicalcpus.cpu_utilization
			uu=node.physicalcpus.cpu_utilization_units
			tram=node.physicalmemory.total
			ramu=100.0*float(node.physicalmemory.used)/float(tram)
			vms=len(node.virtualmachines)
			print "\t%s utilization: VMs: %d CPU: %s%s RAM: %.2fGB used %.2f%%" % (node.name,vms,u,uu,tram/1000.0,ramu)

def usersCMD():
	for user in admin.users:
		name=user.user_id
		belongingToGroups=[]
		for group in user.groups:
			belongingToGroups.append(group.name)
		print "%s (%s)" % (name,",".join(belongingToGroups))

def vlansCMD():
	internalVLANs=[]
	customerVLANs=[]
	for vlan in admin.vlans:
		if vlan.isCustomerVlan:
			customerVLANs.append(vlan)
		else:
			internalVLANs.append(vlan)
	print "Internal VLANs"
	for vlan in internalVLANs:
		print "  %4s %s" % (vlan.vlanid,vlan.name)
	print "Customer VLANs"
	for vlan in customerVLANs:
		print "  %4s %s" % (vlan.vlanid,vlan.name)

def versionCMD():
	print deployer.version


def patternsCMD():
	patterns=deployer.virtualsystempatterns
	patternList=[]
	for p in patterns:
		name=p.app_name
		creator=p.creator
		modified=p.last_modified.replace("T","")
		#patternList.append("%s (%s, %s)" % (name, creator,modified))
		#patternList.append("%s (%s) %s" % (modified,creator,name))
		patternList.append("%s (%s)" % (name,creator))
	patternList.sort()
	print "\n".join(patternList)

def vsysinstancesCMD():
	instances=deployer.virtualsysteminstances
	instanceList=[]
	totalcpu=0
	totalram=0
	totalcount=0
	for instance in instances:
		name=instance.deployment_name
		status=instance.status
		pattern=instance.pattern.app_name
		vms=instance.virtualmachines
		cloudgroup=instance.cloud.name
		vmCount=0
		vmRAM=0
		vmCPU=0
		for vm in vms:
			vmRAM=vmRAM+vm.memory
			vmCPU=vmCPU+vm.cpucount
			vmCount=vmCount+1
		totalcpu=totalcpu+vmCPU
		totalram=totalram+vmRAM
		totalcount=totalcount+vmCount
		instanceStr="%s: %s (%s pattern: %s VMs: %d vCPUs: %d RAM: %.2f GB)" % (cloudgroup,name,status,pattern,vmCount,vmCPU,vmRAM/1000.0)		
		instanceList.append(instanceStr)
	instanceList.sort()
	print "\n".join(instanceList)
	print "Total VM: %d vCPUs: %d RAM %.2f GB" % (totalcount,totalcpu,totalram/1000.0)

def scriptsCMD():
	scripts=deployer.scripts
	total=0
	scriptList=[]
	for script in scripts:
		name=script.name
		desc=script.description
		scriptList.append("%s: %s" % (name,desc))
		total=total+1
	scriptList.sort()
	print "\n".join(scriptList)
	print "Total scripts: %d" % total

def deployCMD():
	ctime=time.strftime("%Y%m%d%H%M%S")
	envProfileName="ipas3-CloudGroup1-Profile-SAP"
	#envProfileName="ipas3-CloudGroup3-Profile"
	patternName="sjs DayTrader NDHADR"
	#patternName="sjs Linux"
	try:
		patternName=sys.argv[5]
	except:
		pass
	print "Deploying sample pattern '%s' to profile '%s'..." % (patternName,envProfileName
		)
	mypattern=deployer.virtualsystempatterns.list({"app_name": patternName})[0] 
	environmentprofile=deployer.environmentprofiles.list({'name':envProfileName})[0]
	deploymentParams={
	'environment_profile':environmentprofile
	}
	virtualInstance=mypattern.deploy("%s %s" % (patternName,ctime),deploymentParams)
	virtualInstanceID=virtualInstance.id 
	print "Pattern %s is deploying. ID: %s" % (patternName,virtualInstanceID)
	f=open("virtualInstanceID","w")
	f.write(virtualInstanceID)
	f.close()

def deploystatusCMD():
	f=open("virtualInstanceID","r")
	virtualInstanceID=f.read().strip()
	f.close()
	instances=deployer.virtualsysteminstances.list({'id':virtualInstanceID})
	if len(instances)==0:
		print "Instance %s does not exist." % (virtualInstanceID)
	else:
		instance=instances[0]
		history=instance.history
		for line in history:
			print "%s: %s" % (line['created_time'],line['current_message'])
		name=instance.deployment_name
		status=instance.status
		print 'Instance "%s"... %s' % (name,status)
		if status=="RUNNING":
			print 'Virtual machines:'
			virtualmachines=instance.virtualmachines
			for vm in virtualmachines:
				name=vm.displayname
				ip=vm.ip
				hostname=ip.userhostname
				ipaddr=ip.ipaddress
				print "  %s (%s): %s" % (hostname,ipaddr,name)

def deploydeleteCMD():
	f=open("virtualInstanceID","r")
	virtualInstanceID=f.read().strip()
	f.close()
	print "Deleting pattern instance...",virtualInstanceID
	instance=deployer.virtualsysteminstances.delete(virtualInstanceID) 


if __name__ == "__main__": 
	main()
