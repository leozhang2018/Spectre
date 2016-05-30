#!/bin/bash
dnsmasqCheck(){

if which dnsmasq > /dev/null;then
	echo "Dnsmasq exists"
	else
	echo "Dnsmasq not exists"
	sudo apt-get update && sudo apt-get install dnsmasq
fi
}
dnsmasqCheck

