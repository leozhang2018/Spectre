#!/bin/bash
#ss-tunnel 进程检测

#shadowsocks.json 配置文件地址
configfile_path="/etc/shadowsockssfo.json"

#ss-tunnel DNS 转发地址及端口
ss_tunnel_address="8.8.4.4:53"

#ss-tunnel DNS 请求监听端口
ss_tunnel_port="7913"

testfile=$(pwd)/processtest.txt	#临时测试文件转存地址当前路径
ps -aux|grep ss-tunnel > ${testfile} 	#进程查询结果转存至 processtest.txt

testing=$(grep "ss-tunnel -c" ${testfile})   	#检测是否存在 ss-tunnel 进程
if [ "${testing}" != "" ]; then
        echo -e "ss-tunnel is still working"
	rm $testfile
fi
if [ "${testing}" = "" ]; then
        echo -e "Oh!! There must be something wrong. :( \nRestarting ss-tunnel"
	nohup ss-tunnel -c $configfile_path -l $ss_tunnel_port -u -L $ss_tunnel_address > /dev/null 2>&1&
	rm $testfile
        exit
fi
