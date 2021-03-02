#!/bin/bash
WORD=$1
LOG=$2
DATE=`date`
if grep $WORD $LOG &> /dev/null
then
logger "$DATE logmon service запущен - найдено ключевое error в логе"
else
exit 0
fi
