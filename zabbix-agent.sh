#!/bin/bash

hostname_defined=$1

echo ""
echo "########## Zabbix Installation Script for CentOS and Ubuntu ##########"
echo ""
authString="linux A9ZVB6YPqxcbdMjCmhT6yJsw5uKNB3"
hostMetaData="$authString "

### Define Variables
ubuntu_jammy_zabbix_repo="https://repo.zabbix.com/zabbix/6.4/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.4-1+ubuntu22.04_all.deb"
ubuntu_xenial_zabbix_repo="https://repo.zabbix.com/zabbix/6.4/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.4-1+ubuntu16.04_all.deb"
ubuntu_focal_zabbix_repo="https://repo.zabbix.com/zabbix/6.4/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.4-1+ubuntu20.04_all.deb"
#centos_5_zabbix_repo="http://repo.zabbix.com/zabbix/3.2/rhel/5/x86_64/zabbix-release-3.2-2.el5.noarch.rpm"
centos_6_zabbix_repo="https://repo.zabbix.com/zabbix/6.4/rhel/6/x86_64/zabbix-release-6.4-1.el6.noarch.rpm"
centos_7_zabbix_repo="https://repo.zabbix.com/zabbix/6.4/rhel/7/x86_64/zabbix-release-6.4-1.el7.noarch.rpm"
zabbix_server="noc-breeze.serverguy.cloud"
zabbix_server_ip="13.200.216.124"


DETECTOS(){
	dist=`grep DISTRIB_ID /etc/*-release | awk -F '=' '{print $2}'`

	if [ "$dist" = "Ubuntu" ]; then
	        os="ubuntu"
	else
	        dist=`cat /etc/*-release | head -1 | awk '{print $1}'`
	        if [ "$dist" = "CentOS" ]; then
	                os="centos"
		else
			yum install facter -y
			dist=`facter operatingsystem`
			if [ "$dist" = "Amazon" ]; then
				os="centos"
			else	
				dist=`grep -w NAME /etc/*-release | awk -F '=' '{print $2}' | tr -d '"'`
				if [ "$dist" = "AlmaLinux" ]; then
					os="Almalinux"
				else
					dist=`grep -w NAME /etc/*-release | awk -F '=' '{print $2}' | tr -d '"'`
					if [ "$dist" = "CloudLinux" ]; then
						os="Cloudlinux"
					fi
				fi
			fi
	        fi
	fi
}

INSTALLDEPENDENCIES(){
	DETECTOS
	if [ "$os" = "ubuntu" ]; then
		echo "Installing dependecies for Ubuntu"
	else
		if [ "$os" = "centos" ]; then
			echo "Installing dependecies for CentOS"
			yum install epel-release -y
		fi
	fi
}

INSTALLCURL(){
	DETECTOS
	if [ "$os" = "ubuntu" ]; then
		apt-get install curl -y
	else
		if [ "$os" = "centos" ]; then
			yum install curl -y
		fi
	fi
}

INSTALLZABBIX(){
	DETECTOS
	if [ "$os" = "ubuntu" ]; then
		version=`cat /etc/*-release | grep DISTRIB_CODENAME | tr "=" " " | awk '{print $2}'`
		if [ "$version" = "jammy" ]; then
			cd
			wget $ubuntu_jammy_zabbix_repo
			dpkg -i zabbix-release_6.4-1+ubuntu22.04_all.deb
			apt-get update -y
			apt-get install zabbix-agent -y
			service zabbix-agent start
			echo "It is Ubuntu and Trusty"
		else
			if [ "$version" = "xenial" ]; then
				cd
				wget $ubuntu_xenial_zabbix_repo
				dpkg -i zabbix-release_6.4-1+ubuntu16.04_all.deb
				apt-get update -y
				apt-get install zabbix-agent -y
				service zabbix-agent start
				systemctl enable zabbix-agent
				echo "It is Ubuntu and Xenial"
	
		
			elif [ "$version" = "focal" ]; then
				cd
				wget $ubuntu_focal_zabbix_repo
				dpkg -i zabbix-release_6.4-1+ubuntu20.04_all.deb
				apt-get update -y
                                apt-get install zabbix-agent -y
                                service zabbix-agent start
                                systemctl enable zabbix-agent
				echo "It is ubuntu and Focal"
			fi
			
		fi
	else
		if [ "$os" = "centos" ]; then
			version=`cat /etc/*-release | head -1 | awk '{print $3}' | tr "." " " | awk '{print $1}'`
			if [ "$version" = "5" ]; then
				cd
				yum clean all
				rpm -ivh $centos_5_zabbix_repo
				yum clean all
				yum install zabbix-agent --disablerepo=* --enablerepo=zabbix -y
				service zabbix-agent start
				echo "It is CentOS and 5"
			else
				if [ "$version" = "6" ]; then
					cd
					yum clean all
					rpm -ivh $centos_6_zabbix_repo
					yum clean all
					yum install zabbix-agent -y
					service zabbix-agent start
					echo "It is CentOS and 6"
				else
					version=`cat /etc/*-release | head -1 | awk '{print $4}' | tr "." " " | awk '{print $1}'`
					if [ "$version" = "7" ]; then
						cd
						yum clean all
						rpm -Uvh $centos_7_zabbix_repo
						yum install zabbix-agent  -y
						service zabbix-agent start
						systemctl enable zabbix-agent
						echo "It is CentOS and 7"
					else
						dist=`facter operatingsystem`
                        			if [ "$dist" = "Amazon" ]; then
                                			version="6"
							cd
                                        		yum clean all
                                        		rpm -ivh $centos_6_zabbix_repo
                                        		yum clean all
                                        		yum install zabbix-agent --disablerepo=* --enablerepo=zabbix -y
                                        		service zabbix-agent start
                                        		echo "It is Amazon Linux AMI"
                        			fi
					fi
				fi
			fi

	else
		if [ "$os" = "Almalinux" ]; then
		rpm -Uvh https://repo.zabbix.com/zabbix/6.4/rhel/8/x86_64/zabbix-release-6.4-1.el8.noarch.rpm
		dnf install zabbix-agent --disablerepo=* --enablerepo=zabbix -y
		echo "It is Almalinux"
		
		elif [ "$os" = "Cloudlinux" ]; then
		rpm -Uvh https://repo.zabbix.com/zabbix/6.4/rhel/8/x86_64/zabbix-release-6.4-1.el8.noarch.rpm
                dnf install zabbix-agent --disablerepo=* --enablerepo=zabbix -y
                echo "It is Cloudlinux"
		fi
	

	fi
	fi
}

UPDATEZABBIXCONFIGURATION(){

	sed -i /Server=127.0.0.1/s/^/#/ /etc/zabbix/zabbix_agentd.conf
	sed -i /ServerActive=/s/^/#/ /etc/zabbix/zabbix_agentd.conf
	sed -i /Hostname=/s/^/#/ /etc/zabbix/zabbix_agentd.conf
	sed -i /HostMetadata=/s/^/#/ /etc/zabbix/zabbix_agentd.conf
	
	echo "Server=$zabbix_server,127.0.0.1" >> /etc/zabbix/zabbix_agentd.conf
	echo "ServerActive=$zabbix_server,127.0.0.1" >> /etc/zabbix/zabbix_agentd.conf
	echo "HostMetadata=$hostMetaData" >> /etc/zabbix/zabbix_agentd.conf
	echo "Hostname=$hostname_defined" >> /etc/zabbix/zabbix_agentd.conf
        echo 'UserParameter=system.topprocessmem, ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head' >> /etc/zabbix/zabbix_agentd.d/custom_values.conf
echo 'UserParameter=system.topprocesscpu, ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head' >> /etc/zabbix/zabbix_agentd.d/custom_values.conf
        
}

ALLOWINFIREWALL(){	
	if which csf > /dev/null 2>&1;then
		csf -a $zabbix_server_ip
		#sed -i '/TCP_IN =/ s/"$/,10050"/' /etc/csf/csf.conf
		csf -r	
	fi
	if which ufw > /dev/null 2>&1;then
		ufw allow from $zabbix_server_ip
		ufw allow 10050
	fi
	iptables-save > /root/iptables.forzabbix.bak.fw
	iptables -I INPUT -p tcp -s $zabbix_server_ip --dport 10050 -j ACCEPT
	iptables -I OUTPUT -d $zabbix_server_ip -j ACCEPT
#	service iptables save
	
}

STARTANDENABLEZABBIX(){
	service zabbix-agent restart
	systemctl enable zabbix-agent
}

INSTALLZABBIX
UPDATEZABBIXCONFIGURATION
ALLOWINFIREWALL
STARTANDENABLEZABBIX

echo $hostMetaData
