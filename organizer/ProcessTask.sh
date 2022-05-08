#!/bin/bash

readdTask(){
./AddToTaskList.sh -q -p $priority -d $1 $2
}

time=$1
date=$2
priority=$3
jobId=$4
task="`echo $@ | cut -d ' ' -f 4-`"

today=`date '+%m/%d/%Y'`
todayEpoc=`date -d $today "+%s"`
dateEpoc=`date -d $date "+%s"` 

if [ $todayEpoc -gt $dateEpoc ] ;then #past events
maskDate=`egrep "^0:" ./dateMasks | cut -d ":" -f 2`
readdTask "$maskDate" "$task"
#elif [ $todayEpoc -lt $dateEpoc ] ;then #we shouldnt process future events
elif [ $todayEpoc -eq $dateEpoc ] ;then  #today events
maskDate=`egrep "^1:" ./dateMasks | cut -d ":" -f 2`
readdTask "$maskDate" "$task"
fi

#todo
#when removing tasks update log 

