#!/bin/bash
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
. /home/MCSManager-Bash/config.sh

#Check Root
[ $(id -u) != "0" ] && { echo "Error: You must be root to run this script"; exit 1; }
#Check OS
if [ -n "$(grep 'Aliyun Linux release' /etc/issue)" -o -e /etc/redhat-release ];then
    OS=CentOS
    [ -n "$(grep ' 7\.' /etc/redhat-release)" ] && CentOS_RHEL_version=7
    [ -n "$(grep ' 6\.' /etc/redhat-release)" -o -n "$(grep 'Aliyun Linux release6 15' /etc/issue)" ] && CentOS_RHEL_version=6
    [ -n "$(grep ' 5\.' /etc/redhat-release)" -o -n "$(grep 'Aliyun Linux release5' /etc/issue)" ] && CentOS_RHEL_version=5
elif [ -n "$(grep 'Amazon Linux AMI release' /etc/issue)" -o -e /etc/system-release ];then
    OS=CentOS
    CentOS_RHEL_version=6
elif [ -n "$(grep bian /etc/issue)" -o "$(lsb_release -is 2>/dev/null)" == 'Debian' ];then
    OS=Debian
    [ ! -e "$(which lsb_release)" ] && { apt-get -y update; apt-get -y install lsb-release; clear; }
    Debian_version=$(lsb_release -sr | awk -F. '{print $1}')
elif [ -n "$(grep Deepin /etc/issue)" -o "$(lsb_release -is 2>/dev/null)" == 'Deepin' ];then
    OS=Debian
    [ ! -e "$(which lsb_release)" ] && { apt-get -y update; apt-get -y install lsb-release; clear; }
    Debian_version=$(lsb_release -sr | awk -F. '{print $1}')
elif [ -n "$(grep Ubuntu /etc/issue)" -o "$(lsb_release -is 2>/dev/null)" == 'Ubuntu' -o -n "$(grep 'Linux Mint' /etc/issue)" ];then
    OS=Ubuntu
    [ ! -e "$(which lsb_release)" ] && { apt-get -y update; apt-get -y install lsb-release; clear; }
    Ubuntu_version=$(lsb_release -sr | awk -F. '{print $1}')
    [ -n "$(grep 'Linux Mint 18' /etc/issue)" ] && Ubuntu_version=16
else
    echo "Does not support this OS, Please contact the author! "
    kill -9 $$
fi


#Get Current Directory
workdir=$(pwd)

#Install Basic Tools
if [[ ${OS} == Ubuntu ]];then
    echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" >> /etc/apt/sources.list
	echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" >> /etc/apt/sources.list
	apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886
	apt-get update
	apt-get install oracle-java8-installer -y
	apt-get install git git-core curl build-essential openssl libssl-dev -y
	git clone https://github.com/nodejs/node.git
    cd node
	git checkout v9.2.0
	./configure
	make
	make install	
fi
if [[ ${OS} == CentOS ]];then
	
	yum install git -y
    
fi
if [[ ${OS} == Debian ]];then
    echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" >> /etc/apt/sources.list
	echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" >> /etc/apt/sources.list
	apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886
	apt-get update
	apt-get install oracle-java8-installer
	apt-get install git git-core curl build-essential openssl libssl-dev -y
	git clone https://github.com/nodejs/node.git
    cd node
	git checkout v9.2.0
	./configure
	make
	make install	
fi

#Install MCSManager and MCSManager-Bash
cd /home
git clone https://github.com/${GH_REPO}.git
git clone https://github.com/Suwings/MCSManager.git
cd /home/MCSManager
npm install --production

#Change CentOS7 Firewall
if [[ ${OS} == CentOS && $CentOS_RHEL_version == 7 ]];then
    systemctl stop firewalld.service
    systemctl disable firewalld.service
fi

#Install MCSManager-Bash
wget -N --no-check-certificate -O /usr/local/bin/Mc https://raw.githubusercontent.com/${GH_REPO}/master/Mc
chmod +x /usr/local/bin/Mc

#INstall Success
bash /usr/local/SSR-Bash-Python/self-check.sh
echo 'MCSManager-Bash v0.1'
echo 'F喵博客地址:https://Fcat.me'
echo '安装完成！访问地址:http://IP:23333/'
echo '初始账号:#master 密码:123456 '
echo 'QQ Group:287215485'