function addEPERepo
{
    #add EPE repositories
    #http://www.cyberciti.biz/faq/rhel-fedora-centos-linux-enable-epel-repo/
    rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

}

function enableCentOSYumRepo
{
    #use only if not access to RedHat repository
    #used mostly during development and setting up stuff
    if [[ "$1" != "" ]] ; then
        CENTOS_VERSION=$1
    else
        CENTOS_VERSION=7
    fi
    REPOFILE=/etc/yum.repos.d/centos.repo
    echo "[centos]" >> $REPOFILE
    echo "name=CentOS \$releasever - \$basearch" >> $REPOFILE
    echo "#Mirror  is in Ireland. see http://www.centos.org/download/mirrors/ for other mirrors." >> $REPOFILE
    echo "baseurl=http://ftp.heanet.ie/pub/centos/$CENTOS_VERSION/os/\$basearch/" >> $REPOFILE
    echo "enabled=1" >> $REPOFILE
    echo "gpgcheck=0" >> $REPOFILE

}
