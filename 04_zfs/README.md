**[Стенд](Vagrantfile) для занятия  «ZFS»**
___

Использован официальный [Vagrant box centos/8 v2011.0](https://app.vagrantup.com/centos/boxes/8)

* CentOS Linux 8.3.2011 / ZFS 0.8.6-1 
* Дополнительные диски (8*200MB) создаются в каталоге `$HOME/VirtualBox VMs/disks`


---

 Цель: Отрабатываем навыки работы с созданием томов export/import и установкой параметров

<h5> <b>1. Определить алгоритм с наилучшим сжатием </b>

Шаги:
- определить какие алгоритмы сжатия поддерживает zfs (gzip gzip-N, zle lzjb, lz4)
- создать 4 файловых системы на каждой применить свой алгоритм сжатия
Для сжатия использовать либо текстовый файл либо группу файлов:
- скачать файл “Война и мир” и расположить на файловой системе
wget -O War_and_Peace.txt http://www.gutenberg.org/ebooks/2600.txt.utf-8
либо скачать файл ядра распаковать и расположить на файловой системе

Результат:
- список команд которыми получен результат с их выводами
- вывод команды из которой видно какой из алгоритмов лучше </h5>
  
___

Всю информацию по ZFS, в том числе про сжатие данных, можно найти в man'e.  
<em>man zfs \compression  
compression=on|off|gzip|gzip-N|lz4|lzjb|zle </em>  
Для алгоритма gzip можно указать параметр 1-9, где 1-максимальная скорость, 9-максимальная степень сжатия.
___

### Практическая часть

>Проверяем какие блочные устройства есть в системе

<em> lsblk </em>
```
[vagrant@otuszfs ~]$ lsblk
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda      8:0    0   10G  0 disk 
└─sda1   8:1    0   10G  0 part /
sdb      8:16   0  200M  0 disk 
sdc      8:32   0  200M  0 disk 
sdd      8:48   0  200M  0 disk 
sde      8:64   0  200M  0 disk 
sdf      8:80   0  200M  0 disk 
sdg      8:96   0  200M  0 disk 
sdh      8:112  0  200M  0 disk 
sdi      8:128  0  200M  0 disk
```

>Создаем пул из 4 дисков

<em> zpool create pool1 mirror sdb sdc mirror sdd sde</em>

>Создаем файловую систему для тестирования сжатия

<em>zfs create pool1/test1  
zfs create pool1/test2  
zfs create pool1/test3  
zfs create pool1/test4  
zfs create pool1/test5</em>

>Применяем различные алгоритмы сжатия

<em>zfs set compression=lz4 pool1/test1  
zfs set compression=zle pool1/test2  
zfs set compression=lzjb pool1/test3  
zfs set compression=gzip-1 pool1/test4  
zfs set compression=gzip-9 pool1/test5 </em> 

>Скачиваем и распаковываем исходники ядра Linux для записи на fs

<em>wget https://mirrors.edge.kernel.org/pub/linux/kernel/v2.0/linux-2.0.1.tar.gz && tar -xvf linux-2.0.1.tar.gz </em>

> Копируем полученные файлы

<em>cp -R /root/linux /pool1/test1/linux  
cp -R /root/linux /pool1/test2/linux  
cp -R /root/linux /pool1/test3/linux  
cp -R /root/linux /pool1/test4/linux  
cp -R /root/linux /pool1/test5/linux  
</em>

>Проверяем какой алгоритм сжатия используется

<em>zfs get compression </em>
```
[root@otuszfs ~]# zfs get compression
NAME         PROPERTY     VALUE     SOURCE
pool1        compression  off       default
pool1/test1  compression  lz4       local
pool1/test2  compression  zle       local
pool1/test3  compression  lzjb      local
pool1/test4  compression  gzip-1    local
pool1/test5  compression  gzip-9    local
```
>Проверяем информацию о степени сжатия

<em> zfs get compressratio </em>
```
[root@otuszfs ~]# zfs get compressratio
NAME         PROPERTY       VALUE  SOURCE
pool1        compressratio  1.97x  -
pool1/test1  compressratio  2.22x  -
pool1/test2  compressratio  1.07x  -
pool1/test3  compressratio  1.93x  -
pool1/test4  compressratio  2.96x  -
pool1/test5  compressratio  3.37x  -
```
><b>В данном конкретном случае приходим к выводу что лучше всего использовать алгоритм сжатия gzip-9 </b>

___
<h5> <b>2. Определить настройки pool’a </b>

Зачем:
Для переноса дисков между системами используется функция export/import. Отрабатываем навыки работы с файловой системой ZFS

Шаги:
- Загрузить архив с файлами локально.
https://drive.google.com/open?id=1KRBNW33QWqbvbVHa3hLJivOAt60yukkg
Распаковать.
- С помощью команды zfs import собрать pool ZFS.
- Командами zfs определить настройки
- размер хранилища
- тип pool
- значение recordsize
- какое сжатие используется
- какая контрольная сумма используется
Результат:
- список команд которыми восстановили pool . Желательно с Output команд.
- файл с описанием настроек settings
- </h5>

>Распакуем полученый файл
```
[root@otuszfs vagrant]# tar -xvf  zfs_task1.tar.gz 
zpoolexport/
zpoolexport/filea
zpoolexport/fileb
```
>С помощью команды zfs import соберем pool ZFS
```
[root@otuszfs vagrant]# zpool import -d /vagrant/zpoolexport/
   pool: otus
     id: 6554193320433390805
  state: ONLINE
 action: The pool can be imported using its name or numeric identifier.
 config:

	otus                            ONLINE
	  mirror-0                      ONLINE
	    /vagrant/zpoolexport/filea  ONLINE
	    /vagrant/zpoolexport/fileb  ONLINE
```

    [root@otuszfs vagrant]# zpool import -d /vagrant/zpoolexport/ otus

> Командами zfs определяем настройки
> 
<em> zfs list otus - размер хранилища  
zfs list otus - размер хранилища  
zpool status otus - тип pool  
zfs get recordsize otus - значение recordsize  
zfs get compression otus - какое сжатие используется  
zfs get checksum otus - какая контрольная сумма используется  </em>
```
[root@otuszfs vagrant]# zfs list otus
NAME   USED  AVAIL     REFER  MOUNTPOINT
otus  2.04M   350M       24K  /otus
otus  2.04M   350M       24K  /otus

[root@otuszfs vagrant]# zpool status otus
  pool: otus
 state: ONLINE
  scan: none requested
config:

	NAME                            STATE     READ WRITE CKSUM
	otus                            ONLINE       0     0     0
	  mirror-0                      ONLINE       0     0     0
	    /vagrant/zpoolexport/filea  ONLINE       0     0     0
	    /vagrant/zpoolexport/fileb  ONLINE       0     0     0

[root@otuszfs vagrant]# zfs get recordsize otus
NAME  PROPERTY    VALUE    SOURCE
otus  recordsize  128K     local

[root@otuszfs vagrant]# zfs get compression otus
NAME  PROPERTY     VALUE     SOURCE
otus  compression  zle       local

[root@otuszfs vagrant]# zfs get checksum otus
NAME  PROPERTY  VALUE      SOURCE
otus  checksum  sha256     local
```
> Суммарный вывод информации о пуле

<em><b>[zfs get all otus](pool-info)</em></b>

___

<h5>
<b>3. Найти сообщение от преподавателей</b>

Зачем:
для бэкапа используются технологии snapshot. Snapshot можно передавать между хостами и восстанавливать с помощью send/receive. Отрабатываем навыки восстановления snapshot и переноса файла.

Шаги:
- Скопировать файл из удаленной директории. https://drive.google.com/file/d/1gH8gCL9y7Nd5Ti3IRmplZPF1XjzxeRAG/view?usp=sharing
Файл был получен командой
zfs send otus/storage@task2 > otus_task2.file
- Восстановить файл локально. zfs receive
- Найти зашифрованное сообщение в файле secret_message

Результат:
- список шагов которыми восстанавливали
- зашифрованное сообщение 
</h5>

>Восстановим полученый snapshot
```
[root@otuszfs vagrant]# zfs receive otus/storage < otus_task2.file

[root@otuszfs vagrant]# zfs list
NAME             USED  AVAIL     REFER  MOUNTPOINT
otus            4.94M   347M       25K  /otus
otus/hometask2  1.88M   347M     1.88M  /otus/hometask2
otus/storage    2.83M   347M     2.83M  /otus/storage
```
> Найдем и прочитаем секретное сообщение
```
[root@otuszfs vagrant]# find /otus -name secret*
/otus/storage/task1/file_mess/secret_message

[root@otuszfs vagrant]# cat /otus/storage/task1/file_mess/secret_message
https://github.com/sindresorhus/awesome
```