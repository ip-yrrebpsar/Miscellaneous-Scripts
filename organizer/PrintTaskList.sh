#!/bin/bash
#set -x
#set -e
today=`date '+%m/%d/%Y'`
printHeader(){
    #Jan 1 2050 -> 01/01/2050
    dateMMDDYYYY=`date -d  "$dateFormat" "+%m/%d/%Y"`
    header=`egrep "$dateMMDDYYYY" ./dateMasks | cut -d ":" -f 3`
    if [ -z "$header" ] ; then 
       if [ "$dateMMDDYYYY" == "$today" ] ; then 
          echo Due Today
       else
          echo "$dateFormat"
       fi
    else
       echo $header
    fi
}
 

atJobs=`atq | sort -k 6n -k 3M -k 4n -k 5 -k 7 -k 1`
sortByPrio(){
#https://stackoverflow.com/questions/7442417/how-to-sort-an-array-in-bash
IFS=$'\n' sorted=($(sort <<<"${taskList[*]}"))
unset IFS
for task in "${sorted[@]}"  ; do 
 echo "     $task"
done
}
taskList=()
while read -u 8 -r line; do
	id=`echo $line |  awk '{ print $1; } '`
	processCommand=`at -c $id | tail -n2 | head -n1 | cut -f 2- -d ';' | tr -d \" ` #eg ./ProcessTask.sh 23:59 05/08/2022 2 task4
 prio=`echo $processCommand | awk '{print $4}'`
 task=`echo $processCommand | cut -d ' ' -f 5-`
 taskFormat="p$prio id:$id | $task "

 dateFormat=`echo $line | awk '{print $3 " " $4 " " $6 }' ` # #May 8 2022

	if [ "$dateFormat" != "$lastDate" ] ; then
      sortByPrio
		echo "" 
      printHeader
      lastDate="$dateFormat"
		taskList=()
	fi
   taskList+=("$taskFormat")
	#		echo  "    $taskFormat"

              #sorts atq by time
done 8< <(atq | sort -k 6n -k 3M -k 4n -k 5 -k 7 -k 1 )
sortByPrio
