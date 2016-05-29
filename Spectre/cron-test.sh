##检查 ss-tunnel 守护进程是否写入 Crontab 函数 CrontabCheck
CheckCrontab(){
        testing=`crontab -l | grep ss-tunnel_alive.sh`          #检测 crontab 是否存在 Update-iptables.sh
        if [ "$testing" != "" ]; then
                                        exit 0
        else
                                file_location=$(pwd)/ss-tunnel_alive.sh
                                echo '*/1 * * * * sh' $file_location >> /etc/cron.d/ss-tunnel_alive
                                echo -e "写入 ss-tunnel 守护脚本至 Crontab 完毕 时间设置 */1 * * * * sh"
        fi
}

#调用 CheckCrontab
CheckCrontab

