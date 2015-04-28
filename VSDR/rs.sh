#!/bin/env bash

sudo ip addr add 10.0.0.10 label lo:vip dev lo

nohup ncat -lk 8964 -c "echo $(hostname) say hello !! " &
