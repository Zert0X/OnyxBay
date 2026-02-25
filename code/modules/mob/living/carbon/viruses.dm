/mob/living/carbon/var/immunity 		= 100		//current immune system strength
/mob/living/carbon/var/immunity_norm 	= 100		//it will regenerate to this value

/mob/living/carbon/proc/get_virus_map()
	return virus2

/mob/living/carbon/proc/has_active_viruses()
	return length(virus2) > 0

/mob/living/carbon/proc/get_virus_copies()
	return virus_copylist(virus2)

/mob/living/carbon/proc/handle_viruses()
	pathogen_runtime.handle_mob(src)

/mob/living/carbon/proc/virus_immunity()
	var/antibiotic_boost = reagents.get_reagent_amount(/datum/reagent/spaceacillin) / (REAGENTS_OVERDOSE/2)
	return max(immunity/100 * (1 + antibiotic_boost), antibiotic_boost)

/mob/living/carbon/proc/immunity_weakness()
	return max(2 - virus_immunity(), 0)
