/datum/space_level/nox_1
	path = 'nox-1.dmm'
	traits = list(
		ZTRAIT_STATION,
		ZTRAIT_CONTACT
	)
	travel_chance = 5

/datum/space_level/nox_2
	path = 'nox-2.dmm'
	traits = list(
		ZTRAIT_STATION,
		ZTRAIT_CONTACT
	)
	travel_chance = 5

/datum/space_level/nox_3
	path = 'nox-3.dmm'
	travel_chance = 15
	traits = list(
		ZTRAIT_CONTACT
	)

/datum/space_level/nox_3/generate(z)
	// Create the mining Z-level.
	new /datum/random_map/automata/cave_system(null, 1, 1, z, 255, 255)
	new /datum/random_map/automata/cave_system/prison(null, 1, 1, z, 255, 255)
	// Create the mining ore distribution map.
	new /datum/random_map/noise/ore(null, 1, 1, z, 255, 255)

/datum/space_level/nox_4
	path = 'nox-4.dmm'
	traits = list(
		ZTRAIT_CENTCOM,
		ZTRAIT_CONTACT,
		ZTRAIT_SEALED
	)