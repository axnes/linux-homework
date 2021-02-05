#!/bin/bash

mdadm --zero-superblock --force /dev/sd{b,c,d,e,f,g,h,i} 2>/dev/null

mdadm --create /dev/md0 -l 10 -n 4 /dev/sd{b,c,d,e}

mdadm --create /dev/md1 -l 5 -n 4 /dev/sd{f,g,h,i}

mkdir /etc/mdadm

echo "DEVICE partitions" > /etc/mdadm/mdadm.conf

mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' >> /etc/mdadm/mdadm.conf



