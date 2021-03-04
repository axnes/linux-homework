**[Стенд](Vagrantfile) для занятия  « Bash.»**
___

Использован официальный [Vagrant box centos/8 v2011.0](https://app.vagrantup.com/centos/boxes/8)

* CentOS Linux 8.3.2011 (1CPU/256RAM)

___

Домашнее задание

<h5> 
Написать скрипт для крона который раз в час присылает на заданную почту

- X IP адресов (с наибольшим кол-вом запросов) с указанием кол-ва запросов c момента последнего запуска скрипта
- Y запрашиваемых адресов (с наибольшим кол-вом запросов) с указанием кол-ва запросов c момента последнего запуска скрипта
- все ошибки c момента последнего запуска
- список всех кодов возврата с указанием их кол-ва с момента последнего запуска
в письме должно быть прописан обрабатываемый временной диапазон
должна быть реализована защита от мультизапуска 

 </h5>
  
___
[`access-4560-644067.log`]() - log файл который нужно анализировать  
[`logparser.sh`]() - непосредственно мой скрипт, при запуске он смотрит количество строк в логе и сохраняет значение в файл lastline. При следущем запуске лог читается с этой строки.  
Защита от повторного запуска реализована с помощью `pidof` При попытке запустить скрипт повторно проверятся PID процесса и если он существует то скрипт не исполняется.

```
[vagrant@localhost vagrant]$ ./logparser.sh 
Script ./logparser.sh is already running: exiting
```
Лог файл скрипта отправляется в локальный ящик:
```
[vagrant@localhost vagrant]$ cat /var/spool/mail/vagrant 

From vagrant@localhost.localdomain  Thu Mar  4 15:37:20 2021
Return-Path: <vagrant@localhost.localdomain>
Received: from localhost.localdomain (localhost [127.0.0.1])
	by localhost.localdomain (8.15.2/8.15.2) with ESMTPS id 124FbKJB024482
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=NOT)
	for <vagrant@localhost.localdomain>; Thu, 4 Mar 2021 15:37:20 GMT
Received: (from vagrant@localhost)
	by localhost.localdomain (8.15.2/8.15.2/Submit) id 124FbK8Z024481
	for vagrant@localhost; Thu, 4 Mar 2021 15:37:20 GMT
Date: Thu, 4 Mar 2021 15:37:20 +0000
From: vagrant@localhost.localdomain
To: vagrant@localhost.localdomain
Subject: Access LOG parser
Message-ID: <20210304153720.GA24479@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
User-Agent: Mutt/1.10.1 (2018-07-13)

Период:[14/Aug/2019:04:12:10 +0300]-[15/Aug/2019:00:25:46 +0300]

IP адреса с наибольшим количеством запросов:
     45 93.158.167.130
     39 109.236.252.130
     37 212.57.117.19
     33 188.43.241.106
     31 87.250.233.68
     24 62.75.198.172
     22 148.251.223.21
     20 185.6.8.9
     17 217.118.66.161
     16 95.165.18.146         

Наиболее запрашиваемые ресурсы:
    157 /
    120 /wp-login.php
     57 /xmlrpc.php
     26 /robots.txt
     12 /favicon.ico
     11 400
      9 /wp-includes/js/wp-embed.min.js?ver=5.0.4
      7 /wp-admin/admin-post.php?page=301bulkoptions
      7 /1
      6 /wp-content/uploads/2016/10/robo5.jpg
      6 /wp-content/uploads/2016/10/robo4.jpg
      6 /wp-content/uploads/2016/10/robo3.jpg
      6 /wp-content/uploads/2016/10/robo2.jpg
      6 /wp-content/uploads/2016/10/robo1.jpg
      6 /wp-content/uploads/2016/10/aoc-1.jpg
      6 /wp-content/uploads/2016/10/agreed.jpg
      6 /wp-content/themes/llorix-one-lite/style.css?ver=1.0.0
      6 /wp-admin/admin-ajax.php?page=301bulkoptions
      5 /wp-includes/js/wp-emoji-release.min.js?ver=5.0.4
      5 /wp-includes/css/dist/block-library/style.min.css?ver=5.0.4

Ошибки
"-"
400
403
404
405
499
500

Все коды возрата их количество:
    498 200
     95 301
     51 404
     11 "-"
      7 400
      3 500
      2 499
      1 405
      1 403
      1 304
```