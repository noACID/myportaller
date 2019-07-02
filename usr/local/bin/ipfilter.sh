#!/bin/bash

ROOT_PATH=$(cd $(dirname $0) && pwd);

sleep 1

IPTABLES="/sbin/iptables"

# External 
EXT_IFACE0="enp2s0"
EXT_IP="162.210.192.19"

INT_IFACE0="eth1"
INT_IFACES="lo"

EXT_IP2="162.210.192.23"

##########################################
# CLEANUP
##########################################
if [ ! -f $ROOT_PATH/ipfilter_clear.sh ]; then
    echo "ipfilter_clear.sh file could not found. Exit"
    exit 1;
fi

$ROOT_PATH/ipfilter_clear.sh

##########################################
# SETUP POLICIES
##########################################

# Setup default policy
$IPTABLES -P INPUT DROP
$IPTABLES -P OUTPUT ACCEPT
$IPTABLES -P FORWARD ACCEPT

##########################################
# KERNEL UPDATE
##########################################

# Enable ipv4 forwarding
echo "1" > /proc/sys/net/ipv4/conf/all/forwarding

##########################################
# INPUT
##########################################


# allow all for local interfaces
for IFACE in $INT_IFACES
do
        $IPTABLES -A INPUT -p ALL -i $IFACE -j ACCEPT
done

# established connections of any type
$IPTABLES -A INPUT -i $EXT_IFACE0 -m state --state ESTABLISHED,RELATED -j ACCEPT

# SSH service
$IPTABLES -A INPUT -i $EXT_IFACE0 -p TCP --dport 22 -j ACCEPT

# DNS service
$IPTABLES -A INPUT -i $EXT_IFACE0 -p udp --destination-port 53 -m string --hex-string "|0000ff0001|" --algo bm -j DROP
$IPTABLES -A INPUT -i $EXT_IFACE0 -p udp --destination-port 53 -j ACCEPT
$IPTABLES -A INPUT -i $EXT_IFACE0 -p tcp --destination-port 53 -j ACCEPT

# HTTP, HTTPS services
$IPTABLES -A INPUT -i $EXT_IFACE0 -p tcp --destination-port 80 -j ACCEPT
$IPTABLES -A INPUT -i $EXT_IFACE0 -p tcp --destination-port 443 -j ACCEPT

# ICMP packets
$IPTABLES -N icmp_packets
$IPTABLES -A icmp_packets -p ICMP -s 0/0 --icmp-type destination-unreachable -j ACCEPT
$IPTABLES -A icmp_packets -p ICMP -s 0/0 --icmp-type time-exceeded -j ACCEPT
$IPTABLES -A icmp_packets -p ICMP -s 0/0 --icmp-type echo-reply -j ACCEPT
$IPTABLES -A icmp_packets -p ICMP -s 0/0 --icmp-type echo-request -j ACCEPT
$IPTABLES -A icmp_packets -j DROP
# icmp
$IPTABLES -A INPUT -i $EXT_IFACE0 -p ICMP -j icmp_packets

##########################################
# POSTROUTING
##########################################
# Default gateway SNAT
$IPTABLES -t nat -A POSTROUTING -o $EXT_IFACE0 -j SNAT --to-source $EXT_IP


#/etc/init.d/fail2ban restart
