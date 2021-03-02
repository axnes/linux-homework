#!/bin/bash

echo '############################################################'
echo '##### Install logmon service              ##################'
echo '############################################################'

cp /vagrant/logmon/logmon.service /etc/systemd/system/logmon.service
cp /vagrant/logmon/logmon.timer /etc/systemd/system/logmon.timer
cp /vagrant/logmon/logmonconf /etc/sysconfig/logmonconf
systemctl enable logmon.timer && systemctl start logmon.timer

echo '############################################################'
echo '##### Install lighttpd service with multi start ############'
echo '############################################################'

cp /vagrant/lighttpd/lighttpd@.service /etc/systemd/system/lighttpd@.service
cp /vagrant/lighttpd/80.conf /etc/lighttpd/80.conf
cp /vagrant/lighttpd/81.conf /etc/lighttpd/81.conf
mkdir -p /var/log/lighttpd80 && mkdir -p /var/www/80
mkdir -p /var/log/lighttpd81 && mkdir -p /var/www/81
chown -R lighttpd:lighttpd /var/log/lighttpd80 && chown -R lighttpd:lighttpd /var/www/80
chown -R lighttpd:lighttpd /var/log/lighttpd81 && chown -R lighttpd:lighttpd /var/www/81
systemctl enable lighttpd@80 && systemctl start lighttpd@80
systemctl enable lighttpd@81 && systemctl start lighttpd@81

echo '############################################################'
echo '##### Install JAVA service with 143 exit code   ############'
echo '############################################################'

mkdir -p /home/vagrant/www
cp /vagrant/code143/miniwebserv.service /etc/systemd/system/miniwebserv.service
systemctl enable miniwebserv && systemctl start miniwebserv

exit 0