/datum/alarm_handler/power
	category = NETWORK_ALARM_POWER

/datum/alarm_handler/power/on_alarm_change(datum/alarm/alarm, was_raised)
	var/area/A = alarm.origin
	if(istype(A))
		A.power_alert(was_raised)
	..()

/area/proc/power_alert(alarming)
