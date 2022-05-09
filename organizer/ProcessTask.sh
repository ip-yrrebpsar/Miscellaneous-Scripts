#!/bin/bash
set -e
set -x
readdTask() {
    ./AddToTaskList.sh -q -p $priority -D $1 $2
}

time=$1
date=$2
priority=$3
jobId=$4

task="$(echo $@ | cut -d ' ' -f 4-)"
today=$(date '+%m/%d/%Y')
todayEpoc=$(date -d $today "+%s")
dateEpoc=$(date -d $date "+%s")

if [ $todayEpoc -ge $dateEpoc ]; then #past events
    maskDate=$(egrep "^1:" ./dateMasks | cut -d ":" -f 2)
    readdTask "$maskDate" "$task"
fi
