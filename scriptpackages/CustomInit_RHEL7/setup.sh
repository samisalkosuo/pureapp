
echo "Init..."

echo "Stop and disable firewall...."
service firewalld stop 
systemctl disable firewalld
service iptables stop
systemctl disable iptables


echo "Enable CentOS repos...."
source functions.sh
enableCentOSYumRepo

if [[ "$ADD_EPEL_REPO" == "true" ]] ; then
  addEPERepo
fi 



echo "install links browser..."
yum -y install links

echo "Install git..."
echo "Default git path: /usr/bin/git"
yum -y install git
