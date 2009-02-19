#!/bin/bash

WIFI=wlan0
SSID=mimiraluzuzu
PASS=55555
SUBNET=192.168.5
IFACE=eth0
#IFACE=ppp0

disable_wpa_roaming()
{
 if [ $(ps -e | grep wpa_supplicant | wc -l) -ge 1 ] ; then
   echo "Disabling WPA roaming..."
   wpa_action $WIFI stop
 fi
}

configure_ad_hoc_wireless_card()
{
 echo "Configuring wireless link..."
 /sbin/iwconfig $WIFI mode ad-hoc essid $SSID channel 1
 #/sbin/iwconfig $WIFI mode managed essid $SSID channel 1
 /sbin/iwconfig $WIFI key s:$PASS
}

configure_interface_address()
{
 echo "Configuring interface address..."
 /sbin/ifconfig $WIFI $SUBNET.1 netmask 255.255.255.0
 sleep 2
 /sbin/ifconfig $WIFI up
}

activate_nat()
{
 echo "Activating NAT.."
 echo "1" > /proc/sys/net/ipv4/ip_forward
 /sbin/iptables -t nat -F
 /sbin/iptables -t nat -A POSTROUTING -s $SUBNET/24 -o $IFACE -j MASQUERADE
 #iptables -t nat -A PREROUTING -i $IFACE -p tcp --dport 15003 -j DNAT --to $SUBNET.2:15003
 #iptables -t nat -A PREROUTING -i $IFACE -p udp --dport 15003 -j DNAT --to $SUBNET.2:15003

 # Cu partea de TTL pus la 1 n-am treaba, RDS nu face (inca) magarii d'astea. Cred ca s-ar rezolva cu:
}

mangle_ttl()
{
 iptables -t mangle -A PREROUTING -i $IFACE -j TTL --ttl-inc 1
 iptables -t mangle -A POSTROUTING -j TTL --ttl-set 64
}

mangle_ttl_raluca()
{
 # iptables -t mangle -A PREROUTING -i $IFACE -j TTL --ttl-inc 1
 # iptables -t mangle -A POSTROUTING -j TTL --ttl-set 64
 echo no ttl mangling for raluca
}

configure_dhserver_regie()
{
 local DHCPSERVER_INTERFACES=/etc/default/dhcp3-server
 local DHCPSERVER_CONF=/etc/dhcp3/dhcpd.conf
 cp $DHCPSERVER_INTERFACES $DHCPSERVER_INTERFACES.back
 echo 'INTERFACES="'$WIFI'"' > $DHCPSERVER_INTERFACES
 
 cp $DHCPSERVER_CONF $DHCPSERVER_CONF.back
 
 echo 'subnet '$SUBNET'.0 netmask 255.255.255.0 {
              range '$SUBNET'.100 '$SUBNET'.200;
              option domain-name-servers 80.96.184.17, 80.96.184.18;
              option domain-name "tvradauti.ro";
              option routers '$SUBNET'.1;
              option broadcast-address '$SUBNET'.255;
              default-lease-time 600;
              max-lease-time 7200;
       }' > $DHCPSERVER_CONF
}


disable_wpa_roaming
configure_ad_hoc_wireless_card
configure_interface_address
activate_nat
mangle_ttl_raluca
configure_dhserver_regie
/etc/init.d/dhcp3-server restart

