#define VIRUS_THRESHOLD 10

/proc/normalize_transmission_channel(channel)
	if(!istext(channel))
		return "contact"
	channel = lowertext(channel)
	switch(channel)
		if("airborne", "contact", "blood")
			return channel
		if("air")
			return "airborne"
	return "contact"

//Returns 1 if mob can be infected, 0 otherwise.
/proc/infection_chance(mob/living/carbon/M, channel = "airborne")
	if(!istype(M))
		return 0

	channel = normalize_transmission_channel(channel)

	var/mob/living/carbon/human/H = M
	if(istype(H) && H.species.get_virus_immune(H))
		return 0

	var/protection = M.get_flat_armor(null, "bio")	//gets the full body bio armour value, weighted by body part coverage.
	var/score = round(0.06*protection)			//scales 100% protection to 6.

	switch(channel)
		if("airborne")
			if(M.internal) //not breathing infected air helps greatly
				return 0
			var/obj/item/I = M.wear_mask
			//masks provide a small bonus and can replace overall bio protection
			if(I)
				score = max(score, round(0.06*I.armor["bio"]))
				if (istype(I, /obj/item/clothing/mask))
					score += 1 //this should be added after

		if("contact", "blood")
			if(istype(H))
				//gloves provide a larger bonus
				if (istype(H.gloves, /obj/item/clothing/gloves))
					score += (channel == "blood" ? 3 : 2)

	switch(score)
		if (6 to INFINITY)
			return 0
		if (5)
			return 1
		if (4)
			return 5
		if (3)
			return 25
		if (2)
			return 45
		if (1)
			return 65
		else
			return 100

//Similar to infection check, but used for when M is spreading the virus.
/proc/infection_spreading_check(mob/living/carbon/M, channel = "airborne")
	ASSERT(istype(M))
	channel = normalize_transmission_channel(channel)

	var/protection = M.get_flat_armor(null, "bio")	//gets the full body bio armour value, weighted by body part coverage.

	if(channel == "airborne")	//for airborne infections face-covering items give non-weighted protection value.
		if(M.internal)
			return 1
		protection = max(protection, M.get_flat_armor(FACE, "bio"))

	return prob(protection + 15*M.chem_effects[CE_ANTIVIRAL])

/proc/airborne_can_reach(turf/simulated/source, turf/simulated/target)
	//Can't ariborne without air
	if(is_below_sound_pressure(source) || is_below_sound_pressure(target))
		return FALSE
	//no infecting from other side of the hallway
	if(get_dist(source,target) > 5)
		return FALSE
	if(istype(source) && istype(target))
		return source.zone == target.zone

/proc/can_transmit_via(mob/living/carbon/source, mob/living/carbon/victim, datum/disease2/disease/disease, channel)
	if(!istype(source) || !istype(victim) || !istype(disease))
		return FALSE

	channel = normalize_transmission_channel(channel)
	if(!disease.supports_transmission_channel(channel))
		return FALSE

	if(infection_spreading_check(source, channel))
		return FALSE

	if(channel == "airborne")
		return airborne_can_reach(get_turf(source), get_turf(victim))

	if(channel == "contact" || channel == "blood")
		return source.Adjacent(victim)

	return FALSE

//Attemptes to infect mob M with virus. Set forced to 1 to ignore protective clothnig
/proc/infect_virus2(mob/living/carbon/M,datum/disease2/disease/disease,forced = 0)
	if(!istype(disease))
		return
	if(!istype(M))
		return
	if((M.status_flags & GODMODE) || (isundead(M)))
		return
	if("[disease.uniqueID]" in M.virus2)
		return
	if(length(M.virus2) > VIRUS_THRESHOLD)
		return
	// if one of the antibodies in the mob's body matches one of the disease's antigens, don't infect
	var/list/antibodies_in_common = M.antibodies & disease.antigen
	if(antibodies_in_common.len)
		return
	if(prob(100 * M.reagents.get_reagent_amount(/datum/reagent/spaceacillin) / (REAGENTS_OVERDOSE/2)))
		return

	if(!disease.affected_species.len)
		return

	if (!(M.species?.name in disease.affected_species))
		if (forced)
			disease.affected_species[1] = M.species.name
		else
			return //not compatible with this species

	var/datum/pathogen_strain/strain = disease.strain
	if(!strain)
		strain = new
		disease.strain = strain
	if(!disease.transmission_mode)
		disease.transmission_mode = strain.TransmissionMode ? strain.TransmissionMode.Copy() : list("contact" = 1)

	var/channel_exposure = 0
	for(var/channel in disease.transmission_mode)
		var/weight = disease.get_transmission_weight(channel)
		if(weight <= 0)
			continue
		channel_exposure += infection_chance(M, channel) * weight

	channel_exposure = min(channel_exposure, 100)
	var/strain_modifier = strain.Infectivity * (0.5 + 0.5 * strain.Shedding)
	var/mob_infection_prob = clamp(channel_exposure * M.immunity_weakness() * strain_modifier, 0, 100)
	if(forced || (prob(disease.infectionchance) && prob(mob_infection_prob)))
		var/datum/disease2/disease/D = disease.getcopy()
		D.minormutate()
		D.update_disease()
		D.infected = M
		M.virus2["[D.uniqueID]"] = D
		BITSET(M.hud_updateflag, STATUS_HUD)

//Infects mob M with random lesser disease, if he doesn't have one
/proc/infect_mob_random_lesser(mob/living/carbon/M)
	var/datum/disease2/disease/D = new /datum/disease2/disease

	D.makerandom(VIRUS_MILD)
	infect_virus2(M, D, 1)

//Infects mob M with random greated disease, if he doesn't have one
/proc/infect_mob_random_greater(mob/living/carbon/M)
	var/datum/disease2/disease/D = new /datum/disease2/disease

	D.makerandom(VIRUS_COMMON)
	infect_virus2(M, D, 1)

//Fancy prob() function.
/proc/dprob(p)
	return(prob(sqrt(p)) && prob(sqrt(p)))

//Checks if the equipment that covers the mouth has bioprotection
/mob/living/carbon/human/proc/can_spread_disease()
	for(var/obj/item/clothing/gear in list(head, wear_mask))
		if(istype(gear) && (gear.body_parts_covered & FACE))
			if(gear.armor["bio"] > 0)
				return FALSE
	return TRUE

/mob/living/carbon/proc/spread_disease_to(mob/living/carbon/victim, channel = "airborne")
	if (src == victim)
		return "retardation"

	channel = normalize_transmission_channel(channel)

	if (virus2.len > 0)
		for (var/ID in virus2)
			var/datum/disease2/disease/V = virus2[ID]
			if(!can_transmit_via(src, victim, V, channel))
				continue
			infect_virus2(victim, V)

	//contact goes both ways
	if (victim.virus2.len > 0 && channel == "contact" && Adjacent(victim))
		var/nudity = 1

		if (ishuman(victim))
			var/mob/living/carbon/human/H = victim

			//Allow for small chance of touching other zones.
			//This is proc is also used for passive spreading so just because they are targeting
			//that zone doesn't mean that's necessarily where they will touch.
			var/touch_zone = zone_sel ? zone_sel.selecting : "chest"
			touch_zone = ran_zone(touch_zone, 80)
			var/obj/item/organ/external/select_area = H.get_organ(touch_zone)
			if(!select_area)
				//give it one more chance, since this is also called for passive spreading
				select_area = H.get_organ(ran_zone())

			if(!select_area)
				nudity = 0 //cant contact a missing body part
			else
				var/list/clothes = list(H.head, H.wear_mask, H.wear_suit, H.w_uniform, H.gloves, H.shoes)
				for(var/obj/item/clothing/C in clothes)
					if(C && istype(C))
						if(C.body_parts_covered & select_area.body_part)
							nudity = 0
		if (nudity)
			for (var/ID in victim.virus2)
				var/datum/disease2/disease/V = victim.virus2[ID]
				if(!can_transmit_via(victim, src, V, "contact"))
					continue
				infect_virus2(src, V)

#undef VIRUS_THRESHOLD
