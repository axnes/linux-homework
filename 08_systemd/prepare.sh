#!/bin/bash

echo '############################################################'
echo '##### Run prepare install.sh              ##################'
echo '############################################################'

yum install -y epel-release
dnf install -y langpacks-en glibc-all-langpacks
yum install -y net-tools wget nano mc java lighttpd


# SELinux
 
# sed -i 's/^SELINUX=.*/SELINUX=permissive/g' /etc/selinux/config
 sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config

setenforce 0

exit 0