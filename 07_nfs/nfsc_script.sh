#!/bin/bash

sudo yum install -y nfs-utils krb5-workstation pam_krb5
sudo systemctl start firewalld rpcbind
sudo systemctl enable rpcbind firewalld
sudo firewall-cmd --permanent --zone=public --add-service=rpc-bind
sudo firewall-cmd --reload
mkdir /mnt/nfs-share
echo '192.168.50.10:/var/nfs/upload /mnt/nfs-share nfs rw,noatime,noauto,x-systemd.automount,proto=udp,vers=3 0 0' | sudo tee -a /etc/fstab > /dev/null
sudo systemctl daemon-reload
sudo systemctl restart remote-fs.target