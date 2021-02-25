#!/bin/sh

_timestamp_now=$(date +"%Y-%m-%d  %T")
_timestamp_hour_ago=$(date -d '1 hour ago' +"%Y-%m-%d %T") #adjust for UTC stored in database
_utc_timestamp_now=$(date -u +"%Y-%m-%d  %T")
_utc_timestamp_hour_ago=$(date -u -d '1 hour ago' +"%Y-%m-%d %T") #adjusted for UTC stored in database
#echo $_timestamp_now $_timestamp_hour_ago $_utc_timestamp_now $_utc_timestamp_hour_ago

_query="SELECT \
        inventory_computer.barcode_id, \
        inventory_computer.serial_number, \
	CONCAT(auth_user.first_name,' ', auth_user.last_name) as owner_name, \
        inventory_computer.room, \
        inventory_make.make, \
	inventory_type.type \
        FROM inventory_computer \
        LEFT JOIN inventory_make ON inventory_computer.make_id=inventory_make.id \
	LEFT JOIN auth_user ON inventory_computer.owner_id=auth_user.id \
	LEFT JOIN inventory_type ON inventory_computer.type_id=inventory_type.id \
        WHERE inventory_computer.added > '${_utc_timestamp_hour_ago}'"

_count_query="SELECT \
        COUNT(inventory_computer.barcode_id) as count
        FROM inventory_computer \
        WHERE inventory_computer.added > '${_utc_timestamp_hour_ago}'"

_number_computers_inserted=$(mysql -u itswebappsdumper -D itswebapps -N -B -e "${_count_query}")

IFS=$'\n'
if [[ $_number_computers_inserted -gt 0 ]]; then

	_computers_added=$(mysql -u itswebappsdumper -D itswebapps -N -B -e "${_query}")
	#echo records
	for _computer in $_computers_added
	do
 		#echo $_computer
		_barcode=$(echo $_computer | awk '{print $1}')
		_serial_number=$(echo $_computer | awk '{print $2}')
		_owner_name=$(echo $_computer | awk '{print $3}')
		_owner_name_last=$(echo $_computer | awk '{print $4}')
		_make=$(echo $_computer | cut -d'	' -f5- | sed 's/\t/ /g')
		#_room=$(echo $_computer | awk '{print $5}')
		#echo $_make
		if [[ ${_make:0:1} == "A" ]]; then
			_article="An"
		else
			_article="A"
		fi
		#echo $_computer
		_message="${_article} ${_make} with the serial number ${_serial_number} for ${_owner_name} ${_owner_name_last} has been tagged with barcode number ${_barcode} and is ready for setup. The ${_make} is in the set-up and test room."
		#echo $_message
		#echo $_barcode $_serial_number $_make $_owner_name $_room
		curl -G --data-urlencode "Description=${_message}" --data-urlencode "Subject=${_barcode}" --data-urlencode 'Action=AddTicket' --data-urlencode 'Key=a6a2db33-7c5c-433c-bc75-f932311ac41c' --data-urlencode 'Priority=Low' --data-urlencode 'Team=Property' --data-urlencode 'Type=Property' --data-urlencode 'Username=winstorm\linda.foster' http://support:80/api.aspx

	done
fi
unset IF
