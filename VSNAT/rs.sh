#!/bin/env bash

sudo yum install man nc nmap vim traceroute tcpdump -y

sudo iptables -I INPUT -p tcp -m tcp --dport 8964 -j ACCEPT

sudo service iptables save

#---------mini-HOWTO-setup-LVS-NAT-realserver-------
#installing default gw 192.168.1.9 for vs-nat'
sudo /sbin/route add default gw 192.168.1.9
#show routing table
sudo netstat -rn

#checking if DEFAULT_GW is reachable
ping -c 1 192.168.1.9

#looking for VIP on director from realserver
ping -c 1 192.168.2.110

#set_realserver_ip_forwarding to OFF (1 on, 0 off).
sudo echo "0" >/proc/sys/net/ipv4/ip_forward
cat       /proc/sys/net/ipv4/ip_forward

#---------mini-HOWTO-setup-LVS-NAT-realserver-------

nohup ncat -lk 8964 -c "echo $(hostname) say hello !! " &
