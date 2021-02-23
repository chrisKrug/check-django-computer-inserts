#!/bin/sh

_timestamp_now=$(date +"%Y-%m-%d  %T")
_timestamp_hour_ago=$(date -d '1 hour ago' +"%Y-%m-%d %T")
#echo $_timestamp_now,$_timestamp_hour_ago

_query="SELECT \
        inventory_computer.barcode_id, \
        inventory_computer.serial_number, \
        inventory_make.make, \
	CONCAT(auth_user.first_name,' ', auth_user.last_name) as owner_name, \
        inventory_computer.room \
        FROM inventory_computer \
        LEFT JOIN inventory_make ON inventory_computer.make_id=inventory_make.id \
	LEFT JOIN auth_user ON inventory_computer.owner_id=auth_user.id \
        WHERE inventory_computer.added > '${_timestamp_hour_ago}'"


_computers_added=$(mysql -u itswebappsdumper -D itswebapps -N -B -e "${_query}")

IFS=$'\n'
#echo $_computers_added
for _computer in $_computers_added
do
	_barcode=$(echo $_computer | awk '{print $1}')
	_serial_number=$(echo $_computer | awk '{print $2}')
	echo $_barcode $_serial_number

done


unset IF
