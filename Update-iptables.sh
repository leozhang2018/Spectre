#!/bin/bash
#iptable-更新(中国区 IP 段)

#shadowsocks.json 配置文件地址
Delegated_apnic_latest_URL="http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest"

#获取后保存的 CN ipv4 文件名
save_to_file="CN_ipv4.txt"

##指定作用域分隔符为 '|',同时计算子网掩码位数之后进行拼接(http://www.cnblogs.com/ggjucheng/archive/2013/01/13/2858470.html)
curl $Delegated_apnic_latest_URL | grep 'apnic|CN|ipv4' | awk -F '|' '/CN/&&/ipv4/ {print "iptables -t nat -I SHADOWSOCKS -d " $4 "/" 32-log($5)/log(2)  " -j RETURN" }'|cat > $save_to_file
