#ifconfig eth0 hw ether 00:11:5B:03:df:d0
ifconfig eth0 hw ether 00:19:b9:5d:09:e8

dhclient eth0
ifconfig eth0 78.97.189.148
route add 78.97.188.1 dev eth0
route add default gw 78.97.188.1
