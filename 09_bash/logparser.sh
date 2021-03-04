#!/bin/bash

PATH="/sbin:/usr/sbin:/usr/local/sbin:/bin:/usr/bin:/usr/local/bin"

if pidof -x $(basename $0) > /dev/null; then
   for p in $(pidof -x $(basename $0)); do
   if [ $p -ne $$ ]; then
   echo "Script $0 is already running: exiting"
    exit
   fi
   done
fi

sleep 3

#Текущее количество строк в логе
lines=$(cat ./access-4560-644067.log | wc -l)

#Количество строк на момент последнего чтения лога
file=./lastline
lastline=$(cat $file 2>/dev/null)

#Проверяем существует ли такой файл,если да то берем его значение для подстановки начальной строки
if [ -s $file ]
then
    starttime=$(cat ./access-4560-644067.log | sed -n "$lastline","$lines"p | awk '{print $4,$5}' | head -n 1)
    endtime=$(cat ./access-4560-644067.log | sed -n "$lastline","$lines"p | awk '{print $4,$5}' | tail -n 1)
    uniqueip=$(cat ./access-4560-644067.log | sed -n "$lastline","$lines"p | awk '{print $1}' | sort | uniq -c | sort -nr | head)
    requests=$(cat ./access-4560-644067.log | sed -n "$lastline","$lines"p | awk '{print $7}' | sort | uniq -c | sort -nr | head -n 20)
    httperror=$(cat ./access-4560-644067.log | sed -n "$lastline","$lines"p | awk '{print $9}' | sed /[1-3]../d | sort | uniq)
    httpcode=$(cat ./access-4560-644067.log | sed -n "$lastline","$lines"p | awk '{print $9}' | sort | uniq -c | sort -nr)
    echo -e "Период:$starttime-$endtime\n\nIP адреса с наибольшим количеством запросов:\n$uniqueip \
        \n\nНаиболее запрашиваемые ресурсы:\n$requests\n\nОшибки\n$httperror\n\nВсе коды возрата их количество:\n$httpcode" | mutt -s 'Access LOG parser' vagrant@localhost
else
    #Если файла со значением строки нет то записываем его и читаем лог полностью
    echo $lines > ./lastline
    starttime=$(cat ./access-4560-644067.log | awk '{print $4,$5}' | head -n 1)
    endtime=$(cat ./access-4560-644067.log | awk '{print $4,$5}' | tail -n 1)
    uniqueip=$(cat ./access-4560-644067.log | awk '{print $1}' | sort | uniq -c | sort -nr | head)
    requests=$(cat ./access-4560-644067.log | awk '{print $7}' | sort | uniq -c | sort -nr | head -n 20)
    httperror=$(cat ./access-4560-644067.log | awk '{print $9}' | sed /[1-3]../d | sort | uniq)
    httpcode=$(cat ./access-4560-644067.log | awk '{print $9}' | sort | uniq -c | sort -nr)
    echo -e "Период:$starttime-$endtime\n\nIP адреса с наибольшим количеством запросов:\n$uniqueip \
        \n\nНаиболее запрашиваемые ресурсы:\n$requests\n\nОшибки\n$httperror\n\nВсе коды возрата их количество:\n$httpcode" | mutt -s 'Access LOG parser' vagrant@localhost
fi

