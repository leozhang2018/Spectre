#eth0_IP="192.168.2.1"
p4p1_ns=`sed '/^p4p1_ns=/!d;s/.*=//' config.ini`
p2p1_ns=`sed '/^p2p1_ns/!d;s/.*=//' config.ini`
#echo $eth0_IP
echo $p4p1_ns
echo $p2p1_ns
