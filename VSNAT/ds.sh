#!/bin/env bash

sudo yum install man nc nmap vim ipvsadm tcpdump traceroute -y

sudo ip addr add 10.0.0.10 label eth1:vip dev eth1

sudo ipvsadm -A -t 10.0.0.10:8689 -s rr
sudo ipvsadm -a -t 10.0.0.10:8689 -r 10.0.1.2:8964 -m
sudo ipvsadm -a -t 10.0.0.10:8689 -r 10.0.1.3:8964 -m

sudo iptables -I INPUT -p tcp -m tcp --dport 8689 -j ACCEPT
sudo service iptables save

#------mini-HOWTO-setup-LVS-NAT-director----------

#set ip_forward ON for vs-nat director (1 on, 0 off).
cat /proc/sys/net/ipv4/ip_forward
sudo echo "1" >/proc/sys/net/ipv4/ip_forward

#director is gw for realservers
#turn OFF icmp redirects (1 on, 0 off)
sudo echo "0" >/proc/sys/net/ipv4/conf/all/send_redirects
cat       /proc/sys/net/ipv4/conf/all/send_redirects
sudo echo "0" >/proc/sys/net/ipv4/conf/default/send_redirects
cat       /proc/sys/net/ipv4/conf/default/send_redirects
sudo echo "0" >/proc/sys/net/ipv4/conf/eth0/send_redirects
cat       /proc/sys/net/ipv4/conf/eth0/send_redirects

#setup VIP
sudo /sbin/ifconfig eth1:110 192.168.2.110 broadcast 192.168.2.255 netmask 255.255.255.0

#set default gateway
sudo /sbin/route add default gw 192.168.2.254 netmask 0.0.0.0 metric 1

#clear ipvsadm tables
sudo /sbin/ipvsadm -C

#install LVS services with ipvsadm
#add telnet to VIP with rr sheduling
sudo /sbin/ipvsadm -A -t 192.168.2.110:8689 -s rr

#first realserver
#forward telnet to realserver 192.168.1.11 using LVS-NAT (-m), with weight=1
sudo /sbin/ipvsadm -a -t 192.168.2.110:8689 -r 192.168.1.11:8964 -m -w 1
#check that realserver is reachable from director
ping -c 1 192.168.1.11

#second realserver
#forward telnet to realserver 192.168.1.12 using LVS-NAT (-m), with weight=1
sudo /sbin/ipvsadm -a -t 192.168.2.110:8689 -r 192.168.1.12:8964 -m -w 1
#checking if realserver is reachable from director
ping -c 1 192.168.1.12

#list ipvsadm table
sudo /sbin/ipvsadm
#------mini-HOWTO-setup-LVS-NAT-director----------
