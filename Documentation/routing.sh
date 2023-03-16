#!/bin/bash

echo "Activation Routage"
echo 1 > /proc/sys/net/ipv4/ip_forward
echo "virification"
cat /proc/sys/net/ipv4/ip_forward

echo
echo "Firewall reset"
iptables -F
iptables -t nat -F

echo
echo "Input DROP"
iptables -P INPUT DROP
echo
echo "Loopback ON"
iptables -A INPUT -i lo -j ACCEPT
echo
#
#
#
# Write Here your Rules 
#
#
#
echo
echo "NAT on for internet access"
iptables -A INPUT -p tcp --dport 80 -m limit --limit 25/minute --limit-burst 100 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -m limit --limit 25/minute --limit-burst 100 -j ACCEPT
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
echo

