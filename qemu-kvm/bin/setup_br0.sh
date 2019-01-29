#!/bin/bash

ip addr flush dev enp2s0
ip link add br0 type bridge
ip link set enp2s0 master br0
ip link set dev br0 up
ip link set dev enp2s0 up
systemctl restart networking
