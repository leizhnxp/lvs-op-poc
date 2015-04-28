#!/bin/env bash

sudo yum install man nc nmap vim ipvsadm tcpdump traceroute -y
sudo iptables -I INPUT -p tcp -m tcp --dport 8964 -j ACCEPT
sudo service iptables save
