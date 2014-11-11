#!/bin/env bash

sudo yum install man nc nmap vim ipvsadm tcpdump traceroute -y

sudo ip addr add 10.0.0.10 label eth1:vip dev eth1

sudo ipvsadm -A -t 10.0.0.10:8964 -s rr
sudo ipvsadm -a -t 10.0.0.10:8964 -r 10.0.0.2 -g
sudo ipvsadm -a -t 10.0.0.10:8964 -r 10.0.0.3 -g

sudo iptables -I INPUT -p tcp -m tcp --dport 8964 -j ACCEPT
sudo service iptables save
