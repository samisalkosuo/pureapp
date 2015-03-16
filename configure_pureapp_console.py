#!/usr/bin/python

#Confifure PureApp settings for console
#This script asks name and other config items
#config is saves as "pureapp_console_<NAME>.sh and to pureapp_console_<NAME>.cmd"
#
#.sh is for Linux/Cygwin and .cmd is for Windows
#note: path is either Linux/Cygwin style or Windows style. You know the platform where you use
#this, so use the correct path.
#
import os
import getpass
print "Configure new PureApp access (Linux/Windows)"

def writeToFile(str,filename):
  f=open(filename,"w")
  f.write(str)
  f.write("\n")
  f.close()


name=raw_input("Name of connection? ")
binfile=raw_input("Directory of Pure CLI binary? ")
host=raw_input("IP/hostname of PureApplication? ")
username=raw_input("Username? ")
password=getpass.getpass("Password (press enter to not store pwd)? ") 

if password=="":
	cmd= "%s/pure -h %s -u %s $*" % (binfile,host,username)
else:
	cmd= "%s/pure -h %s -u %s -p %s $*" % (binfile,host,username,password)

shfile="pureapp_console_%s.sh" % name
writeToFile(cmd,shfile)
print "Written to %s" % shfile
os.chmod(shfile, 0755)

cmd=cmd.replace("/pure ","\\pure.bat ")
cmd=cmd.replace("$*","%*")

cmdfile="pureapp_console_%s.cmd" % name
writeToFile("@echo off\r\n%s" % cmd,cmdfile)
print "Written to %s" % cmdfile

print "Execute %s/.cmd to open console." % (shfile)
print "Execute %s/.cmd -f <script> to execute script." % (shfile)
