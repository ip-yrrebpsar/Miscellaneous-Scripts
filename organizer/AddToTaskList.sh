#!/bin/bash
set -x 
set -e 

scriptDirectory="/home/$USER/Documents/miscScripts/organizer"
if ! [ -d $scriptDirectory ] ; then echo $scriptDirectory not found, update script to where this file is located ; exit 1 ;fi

usage () {
echo ./script some task [ options ] 
echo -n Do not prompt for date, overrides -d
echo -d prompt for date
echo -D supply date in dd/mm/yyyy format
echo -r once the tasks date and time has passed, remove it
echo "-p <1,2,3> | priority default 2"
echo "-t <12:00> | time to prompt about task, no prompt by default"
exit  1
}

parseTime(){
echo unsupported
exit 1 
}

if [ $# -eq 0 ] ; then usage ; fi

#todo if tasks comes before options it doesnt process
while getopts "nqrdD:p:t:" o; do

    case "${o}" in
        t)
            t=${OPTARG}
            parseTime $t
            ;;
        p)
            priority=${OPTARG}
            ((priority >= 1 && priority <= 3))	|| usage
            ;;
        n)
            checkDate=1
            ;;
        q)
            log=1
            ;;
        D)
            date=${OPTARG}
            ;;
        d)
            date=`zenity --calendar`
            ;;
        r)
            echo unsupported
            exit 1 
            ;;
        l)
            usage
            ;;
    esac
done

#shift to isolate task with $@
shift $((OPTIND-1))
#echo "$@"
if [ -z $time ] ; then time="00:00" ; fi 
if [ -z $priority ] ; then priority=2 ; fi 
if [ -z $date ] ; then 
date=`egrep "^3:" ./dateMasks | cut -d ":" -f 2` #user did not set date, use datemask
fi

log=1 # TODO REMOVE ME 
#jobId=`echo "cd $scriptDirectory ; ./ProcessTask.sh $time $date $priority \"$@\"" | at "now" |grep job  | awk '{ print $2 }'`
jobId=`echo "cd $scriptDirectory ; ./ProcessTask.sh $time $date $priority \"$@\"" | at "$time $date" |grep job  | awk '{ print $2 }'`

if [ -z $log ] ; then 
echo $time $date $priority $jobId "$@" >> $scriptDirectory/taskHistory
fi

