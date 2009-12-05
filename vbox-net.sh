#!/bin/bash

# eRegie sets TTL to 1 on all incomming IP pachets.
# The host receives a packet, decrements TTL, sees it to be zero and
# discards the packet.

# This changes the TTL to some number so that the host no longer drops
# the packet and forwards it to the vm.
iptables -t mangle -A POSTROUTING -j TTL --ttl-set 64
