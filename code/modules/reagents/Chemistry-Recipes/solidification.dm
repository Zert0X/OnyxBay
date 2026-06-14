
/* Solidification */

/datum/chemical_reaction/plasmasolidification
	name = "Solid Plasma"
	result = null
	required_reagents = list(/datum/reagent/iron = 5, /datum/reagent/frostoil = 5, /datum/reagent/toxin/plasma = REAGENTS_PER_MATERIAL_SHEET)
	result_amount = 1

/datum/chemical_reaction/plasmasolidification/on_reaction(datum/reagents/holder, created_volume)
	new /obj/item/stack/material/plasma(get_turf(holder.my_atom), created_volume)


/datum/chemical_reaction/plastication
	name = "Plastic"
	result = null
	required_reagents = list(/datum/reagent/acid/polyacid = 5, /datum/reagent/toxin/plasticide = REAGENTS_PER_MATERIAL_SHEET)
	result_amount = 1

/datum/chemical_reaction/plastication/on_reaction(datum/reagents/holder, created_volume)
	new /obj/item/stack/material/plastic(get_turf(holder.my_atom), created_volume)


/datum/chemical_reaction/solidification_glass
	name = "Glass"
	result = null
	required_reagents = list(/datum/reagent/silicate = 1, /datum/reagent/toxin/plasticide = REAGENTS_PER_MATERIAL_SHEET)
	result_amount = 1

/datum/chemical_reaction/solidification_glass/on_reaction(datum/reagents/holder, created_volume)
	new /obj/item/stack/material/glass(get_turf(holder.my_atom), created_volume)


/datum/chemical_reaction/deuterium
	name = "Deuterium"
	result = null
	required_reagents = list(/datum/reagent/water = 10)
	catalysts = list(/datum/reagent/toxin/plasma/oxygen = 5)
	result_amount = 1

/datum/chemical_reaction/deuterium/on_reaction(datum/reagents/holder, created_volume)
	var/turf/T = get_turf(holder.my_atom)
	if(istype(T)) new /obj/item/stack/material/deuterium(T, created_volume)
	return