# Spectre

Linux Server 改造 X86 网关 FQ 路由器计划

文件包含：

 - 安装文件：install.sh
 - Spectre 主程序文件夹:Spectre/
 - dnsmasq 自动配置程序文件夹: dnsmasq-install/

此脚本适用情况以及相关配置:

 - 已经在国外服务器上成功部署 Shadowsocks 服务端
 - 网关服务器要求: Ubuntu Server 14.04 15.10 16.04
 - 双百兆(千兆)网卡已经安装好并配置妥当
 - 需要安装的软件包:
    - isc-dhcp-server
    - dnsmasq
    - [shadowsocks-libev][1]
    - git

##前期准备，基础服务安装

主机安装好 Ubuntu Server 后，请**先执行** `apt-get update (apt update)` 进行相关软件源的更新

根据**实际需求**配置网络接口(`/etc/network/interfaces`)文件，例如：

    # This file describes the network interfaces available on your system
    # and how to activate them. For more information, see interfaces(5).

    # The loopback network interface
    auto lo
    iface lo inet loopback

    # 外网出口网卡接口
    auto eth0
    iface eth0 inet static
    address 192.168.88.53   #外网出口地址，根据服务器对外接入的实际信息填写
    netmask 255.255.255.0
    gateway 192.168.88.1    #外网网关
    dns-nameservers 223.5.5.5 8.8.4.4 114.114.114.114   #DNS 服务器

    # 内网入口网卡接口
    auto eth1
    iface eth1 inet static
    address 192.168.3.1     #外网出口地址
    netmask 255.255.255.0

 安装 DHCP Server(`sudo apt-get install isc-dhcp-server`)，配置 DHCP 服务器（/etc/dhcp/dhcpd.conf）


    #
    # Sample configuration file for ISC dhcpd for Debian
    #
    # Attention: If /etc/ltsp/dhcpd.conf exists, that will be used as
    # configuration file instead of this file.
    # The ddns-updates-style parameter controls whether or not the server will
    # attempt to do a DNS update when a lease is confirmed. We default to the
    # behavior of the version 2 packages ('none', since DHCP v2 didn't
    # have support for DDNS.)
    ddns-update-style none;

    # option definitions common to all supported networks...
    option domain-name "example.org";
    option domain-name-servers ns1.example.org, ns2.example.org;
    default-lease-time 600;
    max-lease-time 7200;

    # If this DHCP server is the official DHCP server for the local
    # network, the authoritative directive should be uncommented.
    #authoritative;

    # Use this to send dhcp log messages to a different log file (you also
    # have to hack syslog.conf to complete the redirection).
    log-facility local7;

    # No service will be given on this subnet, but declaring it helps the
    # DHCP server to understand the network topology.

    #subnet 10.152.187.0 netmask 255.255.255.0 {
    #}

    # This is a very basic subnet declaration.

    #subnet 10.254.239.0 netmask 255.255.255.224 {
    #  range 10.254.239.10 10.254.239.20;
    #  option routers rtr-239-0-1.example.org, rtr-239-0-2.example.org;
    #}

    # This declaration allows BOOTP clients to get dynamic addresses,
    # which we don't really recommend.

    #subnet 10.254.239.32 netmask 255.255.255.224 {
    #  range dynamic-bootp 10.254.239.40 10.254.239.60;
    #  option broadcast-address 10.254.239.31;
    #  option routers rtr-239-32-1.example.org;
    #}

    # A slightly different configuration for an internal subnet.
    #subnet 10.5.5.0 netmask 255.255.255.224 {
    #  range 10.5.5.26 10.5.5.30;
    #  option domain-name-servers ns1.internal.example.org;
    #  option domain-name "internal.example.org";
    #  option routers 10.5.5.1;
    #  option broadcast-address 10.5.5.31;
    #  default-lease-time 600;
    #  max-lease-time 7200;
    #}

    # Hosts which require special configuration options can be listed in
    # host statements.   If no address is specified, the address will be
    # allocated dynamically (if possible), but the host-specific information
    # will still come from the host declaration.

    #host passacaglia {
    #  hardware ethernet 0:0:c0:5d:bd:95;
    #  filename "vmunix.passacaglia";
    #  server-name "toccata.fugue.com";
    #}

    # Fixed IP addresses can also be specified for hosts.   These addresses
    # should not also be listed as being available for dynamic assignment.
    # Hosts for which fixed IP addresses have been specified can boot using
    # BOOTP or DHCP.   Hosts for which no fixed address is specified can only
    # be booted with DHCP, unless there is an address range on the subnet
    # to which a BOOTP client is connected which has the dynamic-bootp flag
    # set.
    #host fantasia {
    #  hardware ethernet 08:00:07:26:c0:a5;
    #  fixed-address fantasia.fugue.com;
    #}

    # You can declare a class of clients and then do address allocation
    # based on that.   The example below shows a case where all clients
    # in a certain class get addresses on the 10.17.224/24 subnet, and all
    # other clients get addresses on the 10.0.29/24 subnet.

    #class "foo" {
    #  match if substring (option vendor-class-identifier, 0, 4) = "SUNW";
    #}

    #shared-network 224-29 {
    #  subnet 10.17.224.0 netmask 255.255.255.0 {
    #    option routers rtr-224.example.org;
    #  }
    #  subnet 10.0.29.0 netmask 255.255.255.0 {
    #    option routers rtr-29.example.org;
    #  }
    #  pool {
    #    allow members of "foo";
    #    range 10.17.224.10 10.17.224.250;
    #  }
    #  pool {
    #    deny members of "foo";
    #    range 10.0.29.10 10.0.29.230;
    #  }
    #}

    subnet 192.168.3.0 netmask 255.255.255.0 {
        # 当 DHCP 客户端主机能够分配的IP地址的范围
        range 192.168.3.201 192.168.3.240;

        # 客户端使用该 IP 地址的租约（以秒计算）
        default-lease-time 86400;
        max-lease-time 86400;

        # 客户端默认网关
        option routers 192.168.3.1;
        # 不从一个网口向另一个网口转发 DHCP 请求
        option ip-forwarding off;

        # 设置客户端广播地址和子网掩码
        option broadcast-address 192.168.3.255;
        option subnet-mask 255.255.255.0;

        # 设置客户端 DNS 服务器，防止被上层 DNS 污染强制使用 ss-tunnel 提供的 DNS
        option domain-name-servers 192.168.3.1;

        # 设置客户端 NTP 服务器
        option nntp-server 192.168.3.1;

        # 如果你为 Windows 客户端指定了一个 WINS 服务器，须在 dhcpd.conf 中加入以下选项
        option netbios-name-servers 192.168.3.1;

        # 也可根据客户端 MAC 地址分配静态 IP (主机名是 "laser-printer"):
        host laser-printer {
          hardware ethernet 08:00:2b:4c:59:23;
          fixed-address 192.168.3.222;
       }
    }

安装 [shadowsocks-libev][1]并根据服务端的配置填写配置文件(/etc/shadowsocks.json)

安装 Dnsmasq (Sudo apt-get install dnsmasq)，**无需手动修改配置文件，后期脚本会自动配置，只需安装即可**


## Spectre 自动配置程序的安装

SSH 登录服务器，clone 或者 Download 该项目至用户目录：
`git clone https://github.com/leozhang2018/Spectre.git`

切换至该项目目录并执行安装程序:
`cd Spectre`
`sudo ./install.sh`

安装结束后，根据程序提示，编辑根目录下的 `/Spectre/config.conf` 填写配置网络接口以及远端服务器信息
vim `/Spectre/config.conf`


    ############################################### Global Config #################################

    #外网出口 IP
    eth0_IP="192.168.88.53"

    #翻墙网段
    p4p1_ns="192.168.3.0/24"

    #不翻墙网段
    p2p1_ns="192.168.88.0/24"

    #shadowsocks.json 配置文件地址:
    configfile_path="/etc/shadowsocks.json"

    #ss-tunnel DNS 转发地址及端口
    ss_tunnel_address="8.8.4.4:53"

    #ss-tunnel DNS 请求监听端口,默认在 `/etc/dnsmasq.d/gfwlist.conf` 中定义
    ss_tunnel_port="7913"

    ############################################### Update-iptables ###############################

    #Apnic 更新地址,用于中国区 IP 列表的更新:
    Delegated_apnic_latest_URL="http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest"

    #获取后保存的 CN ipv4 文件名:
    save_to_file="/Spectre/CN_ipv4.sh"

    ############################################### Shadowsocks Servers############################
    #设置 shadowsocks 规则链服务器 IP 通过规则，即 shadowsocks 远端服务器 IP
    server_IP0="117.28.255.184"
    server_IP1=""
    server_IP2=""
    server_IP3=""
    server_IP4=""
    server_IP5=""
    server_IP6=""
    server_IP7=""
    server_IP8=""
    server_IP9=""

切换至 `/Spectre/dnsmasq-install`，执行 dnsmasq 自动配置程序 `dnsmasq-config.sh`:

`cd /Spectre/dnsmasq-install`
`./dnsmasq-config.sh`

根据程序提示进行配置，至此全部配置工作已经完毕

重启服务器,开机并进行相关测试:
可通过 `dig twitter.com` 查看相关 DNS 是否被污染.
同时将设备接入内置网卡接口，测试是否正常访问相关站点

  [1]: https://shadowsocks.org/en/download/clients.html
