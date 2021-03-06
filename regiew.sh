#!/bin/bash

WIFI=wlan0
SSID=asdfjkl
PASS=55555
SUBNET=192.168.5
#IFACE=eth0
IFACE=ppp0

disable_wpa_roaming()
{
 if [ $(ps -e | grep wpa_supplicant | wc -l) -ge 1 ] ; then
   echo "Disabling WPA roaming..."
   wpa_action $WIFI stop
 fi
}

configure_ad_hoc_wireless_card()
{
 echo "Configuring wireless link... [essid=$SSID]"
 /sbin/iwconfig $WIFI mode ad-hoc essid $SSID channel 1
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
 echo "Activating NAT..."
 echo "1" > /proc/sys/net/ipv4/ip_forward
 /sbin/iptables -t nat -F
 /sbin/iptables -t nat -A POSTROUTING -s $SUBNET/24 -o $IFACE -j MASQUERADE
}

mangle_ttl()
{
 echo "Mangling TTL..."
 iptables -t mangle -A PREROUTING -i $IFACE -j TTL --ttl-inc 1
 iptables -t mangle -A POSTROUTING -j TTL --ttl-set 64
}

configure_dhserver()
{
 echo "Configuring DHCP server..."
 local DHCPSERVER_INTERFACES=/etc/default/dhcp3-server
 local DHCPSERVER_CONF=/etc/dhcp3/dhcpd.conf
 cp $DHCPSERVER_INTERFACES $DHCPSERVER_INTERFACES.back
 echo 'INTERFACES="'$WIFI'"' > $DHCPSERVER_INTERFACES
 
 cp $DHCPSERVER_CONF $DHCPSERVER_CONF.back
 
 echo "subnet "$SUBNET".0 netmask 255.255.255.0 {
              range "$SUBNET".100 "$SUBNET".200;
              option domain-name-servers "`cat /etc/resolv.conf | grep nameserver | cut -d' ' -f 2 | head -c -1 | tr '\n' ','`";
              option domain-name \""`cat /etc/resolv.conf | grep domain | cut -d' ' -f 2 | head -c -1 | tr '\n' ','`"\";
              option routers "$SUBNET".1;
              option broadcast-address "$SUBNET".255;
              default-lease-time 600;
              max-lease-time 7200;
       }" > $DHCPSERVER_CONF
}

disable_nm_wireless()
{
 # disable the wireless connection
 # cnetworkmanager can be found at http://repo.or.cz/w/cnetworkmanager.git
 echo "Disabling NetworkManager managed wireless connection"
 cnetworkmanager --wifi no
}


disable_nm_wireless
disable_wpa_roaming
configure_ad_hoc_wireless_card
configure_interface_address
activate_nat
mangle_ttl
configure_dhserver
/etc/init.d/dhcp3-server restart
if [ ! "x$?" == "x0" ]; then
    echo "Could not restart dhcp3-server. If you don't have it installed run
           'sudo apt-get install dhcp3-server'"
fi
