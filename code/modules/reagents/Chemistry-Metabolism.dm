/datum/reagents/metabolism
	var/metabolism_class //CHEM_TOUCH, CHEM_INGEST, CHEM_BLOOD, or CHEM_DIGEST
	var/mob/living/carbon/parent

/datum/reagents/metabolism/New(max = 1 LITER, mob/living/carbon/parent_mob, met_class)
	..(max, parent_mob)

	metabolism_class = met_class
	if(istype(parent_mob))
		parent = parent_mob

/datum/reagents/metabolism/Destroy()
	parent = null
	. = ..()

/datum/reagents/metabolism/proc/metabolize(forced_only = FALSE)

	var/metabolism_type = 0 //non-human mobs
	if(ishuman(parent))
		var/mob/living/carbon/human/H = parent
		metabolism_type = H.species.reagent_tag

	for(var/datum/reagent/current in reagent_list)
		if(forced_only && !current.forced_metabolism)
			continue
		current.on_mob_life(parent, metabolism_type, metabolism_class)
	update_total()
