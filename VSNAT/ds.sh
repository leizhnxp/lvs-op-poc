#!/bin/env bash

sudo yum install man nc nmap vim ipvsadm tcpdump traceroute -y

sudo ip addr add 10.0.0.10 label eth1:vip dev eth1

sudo ipvsadm -A -t 10.0.0.10:8689 -s rr
sudo ipvsadm -a -t 10.0.0.10:8689 -r 10.0.1.2:8964 -m
sudo ipvsadm -a -t 10.0.0.10:8689 -r 10.0.1.3:8964 -m

sudo iptables -I INPUT -p tcp -m tcp --dport 8689 -j ACCEPT
sudo service iptables save
