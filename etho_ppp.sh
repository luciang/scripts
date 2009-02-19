#!/bin/sh
dhclient eth0
route del default
route del default
route del default 
route add -net 10.0.0.0 netmask 255.0.0.0 gw 10.16.0.1
route add default dev ppp0


while (true); do
	cp /etc/ppp/resolv.conf /etc/resolv.conf
	sleep 5
done
