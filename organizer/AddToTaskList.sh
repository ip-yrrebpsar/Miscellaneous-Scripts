#!/bin/bash
set -e

version="beta"

#todo
#reset counter at 999
#some kind of import/export and restore from logs
#finish unsupported work -t and -r
#log when removing tasks
#add option to remind x days before taskdate
#options dont work if they come after task
#make a readme

scriptDirectory="`dirname $(realpath $0)`"

usage() {
	echo "./script [ options ]  description of your task"
	echo "-d prompt for date"
	echo "-D supply date in dd/mm/yyyy format"
	#echo -r once the tasks date and time has passed, remove it
	echo "-p <1,2,3> | priority default 2"
	#echo "-t <12:00> | time to prompt about task, no prompt by default"
	echo "-v | print version and exit"
 echo "-q | Don't log the task"
	exit 1
}

parseTime() {
	echo unsupported
	exit 1
}

if [ $# -eq 0 ]; then usage; fi

#todo if tasks comes before options it doesnt process
while getopts "nvqrdD:p:t:" o; do

	case "${o}" in
	t)
		t=${OPTARG}
		parseTime $t
		;;
	p)
		priority=${OPTARG}
		((priority >= 1 && priority <= 3)) || usage
		;;
	q)
		log=1
		;;
	D)
		date=${OPTARG}
		;;
	d)
		date=$(zenity --calendar)
		;;
	r)
		echo unsupported
		exit 1
		;;
	l)
		usage
		;;
	v)
		echo $version
		exit
		;;
	esac
done

#shift to isolate task with $@
shift $((OPTIND - 1))

if [ -z $time ]; then time="23:59"; fi
if [ -z $priority ]; then priority=2; fi
if [ -z $date ]; then
	date=$(egrep "^2:" $scriptDirectory/dateMasks | cut -d ":" -f 2) #user did not set date, use datemask
fi
jobId=$(echo "cd $scriptDirectory ; ./ProcessTask.sh $time $date $priority \"$@\"" | at "$time $date" | grep job | awk '{ print $2 }')

if [ -z $log ]; then
	echo add $time $date $priority $jobId "$@" >>$scriptDirectory/taskHistory
fi
