#!/bin/bash
scriptDirectory="`dirname $(realpath $0)`"
cd $scriptDirectory

if [ $# -ne 1 ]  ; then echo Expected id number of task to remove; exit 1 ; fi 
id=$1

if ! [ -f ./PrintTaskList.sh ] ; then echo Expected $0 to be in same directory as PrintTaskList.sh  ;exit 1; fi  
task=`./PrintTaskList.sh | egrep "^ *p[0-9] #$1 \|"`

if [ -z "$task" ] ; then echo Error: task not found ; exit 1 ; fi 
if ! [ -f $scriptDirectory/taskHistory ] ; then echo Expected $0 to be in same directory as taskHistory ; fi  

description=`echo $task | cut -d '|' -f 2-`

if ! grep "$description" $scriptDirectory/taskHistory &> /dev/null ; then 
   echo Info: $task does not appear to be logged, will only remove from todo list
else
   echo "removed on `date '+%b/%d/%Y'` : $task" | tee -a  $scriptDirectory/taskHistory
fi 

atrm $id


