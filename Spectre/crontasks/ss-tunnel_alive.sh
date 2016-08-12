#!/bin/bash

#ss-tunnel 进程检测
# @author leozhang2018 <leozhang2018@gmail.com> 
# @license http://www.opensource.org/licenses/MIT

#载入配置文件
. /Spectre/config.conf

testfile=$(pwd)/processtest.txt	#临时测试文件转存地址当前路径
ps -aux|grep ss-tunnel > ${testfile} 	#进程查询结果转存至 processtest.txt

testing=$(grep "ss-tunnel -c" ${testfile})   	#检测是否存在 ss-tunnel 进程
if [ "${testing}" != "" ]; then
        echo -e "ss-tunnel is still working"
	      rm $testfile
	      exit
fi
if [ "${testing}" = "" ]; then
        echo -e "Oh!! There must be something wrong. :( \nRestarting ss-tunnel"
	      nohup /usr/local/bin/ss-tunnel -c $configfile_path -l $ss_tunnel_port -u -L $ss_tunnel_address > /dev/null 2>&1&
	      rm $testfile
        exit
fi
