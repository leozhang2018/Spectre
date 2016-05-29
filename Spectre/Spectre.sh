#!/bin/bash
# 载入配置文件
. /Spectre/config.conf

# 关闭 dnsmasq 服务，清理 DNS 缓存
service dnsmasq stop
service dns-clean

echo -e "Service dnsmasq stop success \n"

## NAT 搭建软路由
iptables -t filter -A FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -t nat -A POSTROUTING -j SNAT --to-source $eth0_IP


# NAT 网络连通测试
testfile=$(pwd)/pingtest.tx
ping -c3 123.125.114.144 > ${testfile} #Ping baidu 结果转存至pingtest.txt
testing=$(grep "time " ${testfile})   #检测是否 ping 成功出现 time
if [ "${testing}" != "" ]; then
        echo -e "Service NAT start success \n"
        rm $testfile
fi
if [ "${testing}" = "" ]; then
        echo -e "Oh!! There must be something wrong. :( "
        exit
fi

## 开启　dnsmasq 服务
service dnsmasq start
echo -e "Service dnsmasq start success \n"

# 开启 ss-tunnel 准备 DNS 转发
nohup /usr/local/bin/ss-tunnel -c $configfile_path -l $ss_tunnel_port -u -L $ss_tunnel_address > /dev/null 2>&1&
echo -e "Service ss-tunnel start \n "

## 建立 SHADOWSOCKS 规则链
iptables -t nat -N SHADOWSOCKS
# 不翻墙跳出
iptables -t nat -A SHADOWSOCKS -s $p2p1_ns -j RETURN
# CN2 Vtrans
iptables -t nat -A SHADOWSOCKS -d $server_IP0 -j RETURN
iptables -t nat -A SHADOWSOCKS -d $server_IP1 -j RETURN
iptables -t nat -A SHADOWSOCKS -d $server_IP2 -j RETURN
iptables -t nat -A SHADOWSOCKS -d $server_IP3 -j RETURN
iptables -t nat -A SHADOWSOCKS -d $server_IP4 -j RETURN
# Ali BGP 120.24.180.126 (已失效)
iptables -t nat -A SHADOWSOCKS -d $server_IP5 -j RETURN
# Origin IP 128.199.76.169 128.199.250.243 198.199.116.70 104.236.177.117
iptables -t nat -A SHADOWSOCKS -d $server_IP6 -j RETURN
iptables -t nat -A SHADOWSOCKS -d $server_IP7 -j RETURN
iptables -t nat -A SHADOWSOCKS -d $server_IP8 -j RETURN
iptables -t nat -A SHADOWSOCKS -d $server_IP9 -j RETURN
echo -e "Create shadowsocks chain success \n"

## 局域网 IP
iptables -t nat -A SHADOWSOCKS -d 240.0.0.0/4 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 224.0.0.0/4 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 172.16.0.0/12 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 169.254.0.0/16 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 127.0.0.0/8 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 0.0.0.0/8 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 10.0.0.0/8 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 192.168.0.0/16 -p tcp -j RETURN
echo -e "Input LAN IP success \n"

# 将其他 IP 导向 SS
iptables -t nat -A SHADOWSOCKS -p tcp -j REDIRECT --to-ports 1080
# 将所有 tcp 数据包 导向 SHADOWSOCKS 规则
iptables -t nat -A PREROUTING -p tcp -j SHADOWSOCKS
echo -e "Shadowsocks chain start \n"

# 开启 tcp 包转发
nohup /usr/local/bin/ss-redir -c $configfile_path -d start >/dev/null 2>&1&
echo -e "Service ss-redir start \n"

## 载入 CN iptable 设置
. $save_to_file

echo -e "Input China IP rules success"


##检查 ss-tunnel 守护进程是否写入 Crontab 函数 CrontabCheck
CheckCrontab(){
	cron="/etc/cron.d/ss-tunnel_alive"  	#检测 crontab 是否存在 Update-iptables.sh
	if test -s $cron ;then
				exit 0
	else
			 	file_location=/Spectre/crontasks/ss-tunnel_alive.sh
				echo '*/1 * * * * root bash' $file_location '>/dev/null 2>&1' >> /etc/cron.d/ss-tunnel_alive
				echo -e "写入 ss-tunnel 守护脚本至 Crontab 完毕 时间设置 */1 * * * * sh"
	fi
}

#调用 CheckCrontab
CheckCrontab

echo -e "All done"
exit 0
