#!/bin/bash

sudo yum install -y nfs-utils krb5-server krb5-workstation pam_krb5
sudo systemctl enable firewalld rpcbind nfs-server
sudo systemctl start firewalld rpcbind nfs-server
sudo firewall-cmd --permanent --zone=public --add-service=nfs
sudo firewall-cmd --permanent --zone=public --add-service=mountd
sudo firewall-cmd --permanent --zone=public --add-service=rpc-bind
sudo firewall-cmd --permanent --zone=public --add-port=2049/udp
sudo firewall-cmd --reload
mkdir -p /var/nfs/upload && chmod -R 777 /var/nfs
echo '/var/nfs/upload 192.168.50.0/24(rw,sync,no_root_squash,no_all_squash)' | sudo tee -a /etc/exports > /dev/null
sudo exportfs -r