#!/bin/env bash

sudo yum install man nc nmap vim traceroute tcpdump -y
sudo ip addr add 10.0.0.10 label lo:vip dev lo

sudo iptables -I INPUT -p tcp -m tcp --dport 8964 -j ACCEPT
sudo service iptables save

nohup ncat -lk 8964 -c "echo $(hostname) say hello !! " &
