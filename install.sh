#!/bin/bash

# Spectre 安装文件
# @author leozhang2018 <leozhang2018@gmail.com> 
# @license http://www.opensource.org/licenses/MIT



## root 环境检查函数
function checkRoot(){
if [ $UID -ne 0 ]; then
        echo "非 root 用户请切换至 root 用户执行"
        exit 1
fi

}

## ipv4_CN iptable 的定时自动更新函数
IptableIntoCrontab(){
	cron="/etc/cron.d/Update-iptables" #检测 crontab 是否存在 Update-iptables.sh
	if test -s $cron ;then
			echo "更新 iptable 的 Cron 任务已经存在"
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

# 检查 root 环境
checkRoot

##复制程序目录
sudo cp -R Spectre /Spectre

##更改权限
sudo chmod -R 775 /Spectre

##开启 IP 数据包转发
sysctl -w net.ipv4.ip_forward=1 >> /dev/null

##将 Spectre.sh 脚本添加至开机启动项
echo "/Spectre/Spectre.sh \nexit 0"  >> /etc/rc.local

## 是否进行 ipv4_CN iptable 的定时自动更新
IptableIntoCrontab

##提示用户修改配置文件
echo "安装完毕,请修改位于 /Spectre 目录下的配置文件 config.conf"
