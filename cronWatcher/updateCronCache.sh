#!/bin/bash
#This script will walk the inventory file and update cached crontabs and inventory md5sums

#TODO
#options for always/never overwrite without prompt 
#show diff of crontabs if overwriting 
#only try to update if different

scriptDirectory="`dirname $(realpath $0)`"
mkdir -p "$scriptDirectory/cronCache"

updateInventoryMd5(){
	newMd5=`echo "$discoveredCron" | grep -ve "^ *#" | tr -d '\n' | md5sum | awk '{print $1}' `
	inventory=`cat "$scriptDirectory/inventory.json"`

	if ! [ -f inventory_`date '+%m-%d-%Y'`.bak ] ;then 
		cp  inventory.json inventory_`date '+%m-%d-%Y'`.bak
	fi
	echo "$inventory"  | jq ".$endpointAlias.md5 = \"$newMd5\"" > inventory.json
}

writeCronCache(){ 
	if [ $1 -ne 0 ] ; then 
		echo "failed to retreieve crontab for $cronUser, for endpoint $endpointAlias"
	else
		echo "$discoveredCron" > "./cronCache/$endpointAlias"
		updateInventoryMd5
	fi
}

updateLocalInventory(){
	discoveredCron=`crontab -u $cronUser -l ` #| grep -ve "^ *#" | tr -d '\n'  `
	writeCronCache $?
}

updateRemoteInventory(){
	if ! [ -f "$identity" ] ; then 
		echo "failed to find identityFile $identity for $endpointAlias"
	else
		discoveredCron=`ssh -i "$identity" "$identityUser@$endpoint" "crontab -u $cronUser -l "`
		writeCronCache $?
	fi
}

prompt(){
	echo overwrite existing cached crontab ./cronCache/$endpointAlias and update inventory with new md5? [y/n]
	read answer
	if [ "$answer" == "y" ] || [ "$answer" == "Y" ] ; then
		return 0
	fi
	return 1 
}

inventory=`cat "$scriptDirectory/inventory.json"`
endpoints=`echo $inventory | jq 'keys'  `
for endpointAlias in `echo $endpoints | jq -c .[] --raw-output` ; do 
	hostType=`echo "$inventory"  | jq .$endpointAlias.type --raw-output`
	cronUser=`echo "$inventory"  | jq .$endpointAlias.cronUser --raw-output` 

	if [ "$hostType" == "local" ] ; then
		if ! [ -f ./cronCache/$endpointAlias ] || prompt ; then
			echo Caching new crontab for $endpointAlias
			updateLocalInventory
		fi
	elif [ "$hostType" == "remote" ] ; then
		identityUser=`echo $inventory  | jq .$endpointAlias.identityUser --raw-output`
		endpoint=`echo $inventory  | jq .$endpointAlias.endpoint --raw-output`
		identity=`echo $inventory  | jq .$endpointAlias.identityFile --raw-output`

		if ! [ -f ./cronCache/$endpointAlias ] || prompt ; then
			echo Caching new crontab for $endpointAlias
			updateRemoteInventory
		fi
	fi
done

