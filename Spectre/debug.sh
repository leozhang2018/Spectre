#!/bin/bash
echo "######################### BOOT LOG ###################"
echo -e "\n"
tail /var/log/boot.log
echo -e "\n"

echo "######################### CRON LOG ###################"
echo -e "\n"
tail /var/log/cron.log

echo "######################### Dnsmasq in /etc/dnsmasq.conf ###################"
echo -e "\n"
tail /etc/dnsmasq.conf
