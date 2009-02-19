#! /bin/bash
route del 10.16.4.1
route add 10.16.0.1 dev eth0
route add 10.0.0.0 gw 10.16.0.1
route add default ppp0

