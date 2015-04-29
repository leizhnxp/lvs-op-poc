#!/bin/env bash

sudo ip addr add 10.0.0.10 label lo:vip dev lo

sudo sh -c "echo 1 > /proc/sys/net/ipv4/conf/all/arp_ignore;echo 1 > /proc/sys/net/ipv4/conf/lo/arp_ignore;echo 2 > /proc/sys/net/ipv4/conf/lo/arp_announce;echo 2 > /proc/sys/net/ipv4/conf/all/arp_announce"

nohup ncat -lk 8964 -c "echo $(hostname) say hello !! " &
