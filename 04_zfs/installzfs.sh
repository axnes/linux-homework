#!/bin/bash

yum install -y yum-utils epel-release

sudo yum -y install https://zfsonlinux.org/epel/zfs-release.el8_3.noarch.rpm
gpg --quiet --with-fingerprint /etc/pki/rpm-gpg/RPM-GPG-KEY-zfsonlinux
yum-config-manager --enable zfs-kmod
yum-config-manager --disable zfs
yum install -y zfs
modprobe zfs
yum install -y htop
sudo sh -c "echo zfs >/etc/modules-load.d/zfs.conf"
