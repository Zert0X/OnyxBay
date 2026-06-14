/atom/proc/supermatter_act()
	CAN_BE_REDEFINED(TRUE)
	return FALSE

/mob/supermatter_act()
	dust()
	return TRUE

/obj/supermatter_act()
	new /obj/effect/decal/cleanable/ash(loc)
	qdel_self()
	return TRUE

/turf/simulated/wall/supermatter_act()
	new /obj/effect/decal/cleanable/ash(src)
	dismantle_wall(no_product = TRUE)
	return TRUE
