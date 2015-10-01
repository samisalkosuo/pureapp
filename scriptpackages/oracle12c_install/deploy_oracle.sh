#!/bin/sh

#Set up Linux and oracle
echo "Deploying Oracle..."

if [[ "$1" != "" ]] ; then
	DEFAULT_PWD=$1
	echo "Using user specified default password"
else
	DEFAULT_PWD=passW0RD 
fi

echo "Install prereqs..."
sh prereq.sh
echo "Install prereqs...done."
echo "Install Oracle..."
sh install.sh $DEFAULT_PWD
echo "Install Oracle...done."
echo "Set up Oracle..."
sh setup_db.sh $DEFAULT_PWD
echo "Set up Oracle...done."
echo "Deploying Oracle...done."
