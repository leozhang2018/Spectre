#!/bin/bash

## Spectre 安装文件

## ipv4_CN iptable 的定时自动更新函数
IptableIntoCrontab(){
	cron="/etc/cron.d/Update-iptables" #检测 crontab 是否存在 Update-iptables.sh
	if test -s $cron ;then
					exit
	else
			echo "是否进行 ipv4_CN iptable 的定时自动更新?(yes or no)"
			read input
			file_location=/Spectre/crontasks/Update-iptables.sh
			  if [ "$input" == "yes" -o "$input" == "Yes" ]; then
			       #每个月总有那么一次
				     echo '* * 1 * * sh root bash' $file_location '/dev/null 2>&1' >> /etc/cron.d/Update-iptables
				     echo -e "写入 Crontab 完毕 时间设置每月定时更新"
				else
					   exit 0
				fi
	fi
}

##复制程序目录
sudo cp -R Spectre /Spectre

##更改权限
sudo chmod -R 775 /Spectre

##将 Spectre.sh 脚本添加至开机启动项
echo '/Spectre/Spectre.sh \nexit 0'  >> /etc/rc.local

## 是否进行 ipv4_CN iptable 的定时自动更新
IptableIntoCrontab

##提示用户修改配置文件
echo "安装完毕,请修改位于 /Spectre 目录下的配置文件 config.conf"
