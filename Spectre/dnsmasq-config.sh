#!/bin/bash
# dnsmasq 导入配置脚本

# 载入 Spectre 配置文件
. /Spectre/config.conf

# 载入 dnsmasq 配置函数
function dnsmasqImportConf(){

	  # 载入 dnsmasq 配置
    . /Spectre/dnsmasq.conf.sh >> /etc/dnsmasq2.conf

}

function dnsmasqCheck(){

if which dnsmasq > /dev/null;then
  # 如果已经安装 dnsmasq
	echo -e "Dnsmasq exists \n"
      #检测 dnsmasq 是否运行
      #systemd
	if  service dnsmasq status|grep "Active: active" >> /dev/null ;then #Bug
      #若运行则停止服务
      sudo service dnsmasq stop
      #载入 dnsmasq 配置
    	dnsmasqImportConf
      else
      #载入 dnsmasq 配置
      dnsmasqImportConf
  fi

	else
	   echo -e "Dnsmasq not install \n"
     #安装 dnsmasq
	   sudo apt-get update && sudo apt-get install dnsmasq
	   #载入 dnsmasq 配置
     dnsmasqImportConf
fi

}

#复制已有的配置文件至 /etc/dnsmasq.d
function importDnsmasqd(){

#复制文件
sudo cp -R /Spectre/dnsmasq.d /etc

}


# 运行 dnsmasqCheck 函数
dnsmasqCheck

# 运行复制配置函数 importDnsmasqd
importDnsmasqd

# 重启dnsmasq 服务
sudo service dnsmasq restart
