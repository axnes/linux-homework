**[Стенд](Vagrantfile) для занятия  « Инициализация системы. Systemd.»**
___

Использован официальный [Vagrant box centos/8 v2011.0](https://app.vagrantup.com/centos/boxes/8)

* CentOS Linux 8.3.2011 (1CPU/256RAM)

___

Домашнее задание

<h5> 
1. Cоздать сервис и unit-файлы для этого сервиса:

Cервис: скрипт, который мониторит log-файл на наличие ключевого слова  
● ключевое слово и путь к log-файлу должны браться из /etc/sysconfig/ (.service)  
● сервис должен активироваться раз в 30 секунд (.timer)

2.Дополнить unit-файл сервиса httpd возможностью запустить несколько экземпляров сервиса с разными конфигурационными файлами.

3.Создать unit-файл(ы) для сервиса:  
● Cервис: Kafka, Jira или любой другой у которого код успешного завершения не равен 0 (к примеру, приложение Java или скрипт с exit 143)  
● ограничить сервис по использованию памяти (ещё по трём ресурсам, которые не были рассмотрены на лекции)  
● реализовать один из вариантов restart и объяснить почему выбран именно этот вариант.  
* реализовать активацию по .path или .socket

 </h5>
  
___

1.Добавлен сервис `logmon.service` вызываемый таймером `logmon.service`. Он запускает скрипт `logmon.sh` и проверяет тестовый лог файл (/vagrant/testlog.log) на наличие ключевого слова `error`. В случае обнаружения `logger` делает запись в системном журнале.

```
[root@localhost vagrant]# journalctl -n 10
Mar 02 13:02:00 localhost.localdomain systemd[1]: Started logmon service.
Mar 02 13:02:00 localhost.localdomain root[2419]: Tue Mar  2 13:02:00 UTC 2021 logmon service запущен - найдено ключевое error в логе
Mar 02 13:02:00 localhost.localdomain systemd[1]: logmon.service: Succeeded.
```

2.Для реализаци шаблона используется Lighttpd.

lighttpd@.service запускает несколько экземляров сервера с разными конфигурационными файлами и на разных портах (80 и 81)

```
[root@localhost vagrant]# netstat -tanp 
Active Internet connections (servers and established)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name    
tcp        0      0 0.0.0.0:111             0.0.0.0:*               LISTEN      1/systemd           
tcp        0      0 0.0.0.0:80              0.0.0.0:*               LISTEN      635/lighttpd        
tcp        0      0 0.0.0.0:81              0.0.0.0:*               LISTEN      630/lighttpd        
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      631/sshd 
```

3.Для выполнения третьего пункта в задани я использовал [Jibble Web Server](http://www.jibble.org/jibblewebserver.php). Когда мы останавливаем службу «systemctl stop», то шлётся сигнал SIGTERM с кодом завершения приложения 15, который по умолчанию для службы считается успешным. Но джава завершается с кодом 143, так как следует Posix спецификации.
```
[root@localhost vagrant]# cat /etc/systemd/system/miniwebserv.service 
[Unit]
Description = Simple JAVA web server
After=network.target

[Service]
User=vagrant
NoNewPrivileges=true
MemoryLimit=35M
MemorySwapMax=10M
CPUQuota=10%
TasksMax=20
IPAddressAllow=127.0.0.0/8
WorkingDirectory=/vagrant/code143
ExecStart=/usr/bin/java -jar WebServerLite.jar /home/vagrant/www/ 8080
SuccessExitStatus=143
Restart=always
StartLimitInterval=90
StartLimitBurst=5

[Install]
WantedBy=multi-user.target
```
Сервис ограничен по потреблению памяти, swap, максимальному количеству задач порождаемых юнитом, потреблению процессорного времени. Опция перезапуска выставлена в Restart=always что бы приложение работало всегда и его нельзя было случайно завершить. Systemd будет пытаться перезапустить его несколько раз в течении заданого интеревала времени.

Сервис доступен на порту 8080, мы можем обратиться к нему и получить ответ от сервера:

```
[root@localhost vagrant]# curl 127.0.0.1:8080
<h1>Directory Listing</h1><h3>/</h3><table border="0" cellspacing="8"><tr><td><b>Filename</b><br></td><td align="right"><b>Size</b></td><td><b>Last Modified</b></td></tr><tr><td><b><a href="../">../</b><br></td><td></td><td></td></tr></table><hr><i><a href="http://www.jibble.org">Jibble Web Server 1.0</a> - An extremely small Java web server</i>[root@localhost vagrant]# 
```
