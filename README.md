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

安装以及使用方法参见 wiki: [ Spectre 使用指南 ][3]

  [1]: https://shadowsocks.org/en/download/clients.html
  [2]: https://shadowsocks.org/en/download/clients.html
  [3]:https://github.com/leozhang2018/Spectre/wiki/Spectre-%E4%BD%BF%E7%94%A8%E6%8C%87%E5%8D%97
