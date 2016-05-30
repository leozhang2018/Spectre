#!/bin/bash
# dnsmasq 导入配置脚本


# 载入 dnsmasq 配置函数
dnsmasqImportConf(){

	# 载入 dnsmasq 配置
        . /Spectre/dnsmasq.conf.sh >> /etc/dnsmasq2.conf

}

dnsmasqCheck(){

if which dnsmasq > /dev/null;then
	echo -e "Dnsmasq exists \n"
	#载入 dnsmasq 配置
	dnsmasqImportConf
	else
	echo -e "Dnsmasq not exists \n"
	sudo apt-get update && sudo apt-get install dnsmasq
	#载入 dnsmasq 配置
        dnsmasqImportConf
fi

}
# 运行 dnsmasqCheck 函数
dnsmasqCheck

# 重启dnsmasq 服务
sudo service dnsmasq restart
