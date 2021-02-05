Centos 7 box с кастомным ядром внутри

 yum update

 yum install -y rpm-build redhat-rpm-config asciidoc hmaccalc perl-ExtUtils-Embed pesign xmlto audit-libs-devel binutils-devel elfutils-devel elfutils-libelf-devel ncurses-devel newt-devel numactl-devel pciutils-devel python-devel zlib-devel gcc patchutils bc flex openssl-devel wget bison make gcc redhat-rpm-config
 cd /usr/src/

 wget https://cdn.kernel.org/pub/linux/kernel/v3.x/linux-3.16.82.tar.xz

 tar -xvf linux-3.16.82.tar.xz

 cd linux-3.16.82/

 cp -v /boot/config-3.10.0-1062.12.1.el7.x86_64 /home/vagrant/linux-3.16.82/.config

 make olddefconfig

 make bzImage && make modules && make

 make modules_install && make install

 grub2-mkconfig -o /boot/grub2/grub.cfg

 grub2-set-default 0

 reboot


