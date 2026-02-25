LEGACY_RECORD_STRUCTURE(virus_records, virus_record)

/datum/disease2/disease
	var/infectionchance = 70
	var/speed = 1
	var/spreadtype = "Contact" // Can also be "Airborne"
	var/list/transmission_mode = list("airborne" = 0, "contact" = 1, "blood" = 0)
	var/stage = 1
	var/dead = 0
	var/clicks = 0
	var/uniqueID = 0
	var/list/datum/disease2/effect/effects = list()
	var/mob/living/carbon/human/infected = null // Someone who will suffer from disease
	var/antigen = list() // 16 bits describing the antigens, when one bit is set, a cure with that bit can dock here
	var/max_stage = 4
	var/list/affected_species = list(SPECIES_HUMAN, SPECIES_UNATHI, SPECIES_SKRELL, SPECIES_TAJARA, SPECIES_SWINE)
	var/datum/pathogen_profile/profile
	var/datum/pathogen_strain/strain
	var/datum/pathogen_culture/culture
	var/datum/pathogen_knowledge/knowledge
	var/model_managed = FALSE

/datum/disease2/disease/New(random_severity = 0)
	profile = new
	strain = new
	culture = new
	knowledge = new
	model_managed = (src.type == /datum/disease2/disease)
	uniqueID = rand(0, 10000)
	strain.strain_id = uniqueID
	set_legacy_spreadtype(spreadtype)
	if(random_severity)
		makerandom(random_severity)
	else if(model_managed)
		strain.initialize_random()
		transmission_mode = strain.TransmissionMode ? strain.TransmissionMode.Copy() : transmission_mode
		spreadtype = derive_legacy_spreadtype()
		rebuild_effects_from_strain()
		sync_knowledge_from_model()

/datum/disease2/disease/proc/update_disease()
	if(model_managed)
		strain.strain_id = uniqueID
		strain.recompute_phenotype()
		if(strain.TransmissionMode)
			transmission_mode = strain.TransmissionMode.Copy()
		spreadtype = derive_legacy_spreadtype()
		rebuild_effects_from_strain()
		sync_knowledge_from_model()
	else
		set_legacy_spreadtype(spreadtype)
		sync_knowledge_from_effects()

	var/list/datum/disease2/effect/effects_sorted = list() //Sort effects by stage

	for(var/i in 1 to max_stage)
		for(var/datum/disease2/effect/D in effects)
			if(D.stage == i)
				effects_sorted.Add(D)

	effects = effects_sorted
	if(!antigen)
		antigen = list(pick(ALL_ANTIGENS))
		antigen |= pick(ALL_ANTIGENS)

	if(infected) //if virus mutated inside human, update his virus2
		for(var/ID in infected.virus2)
			var/datum/disease2/disease/V = infected.virus2["[ID]"]
			if(V.uniqueID != ID)
				infected.virus2.Remove("[ID]")
				infected.virus2["[V.uniqueID]"] = V

	for(var/datum/disease2/effect/E in effects)
		E.parent_disease = src
		E.change_parent()

/datum/disease2/disease/proc/makerandom(severity = 2)
	if(model_managed)
		strain.initialize_random()
		rebuild_effects_from_strain()
	uniqueID = rand(0, 10000)
	strain.strain_id = uniqueID
	switch(severity)
		if(1, 2)
			infectionchance = rand(10, 20)
		else
			infectionchance = rand(60, 90)

	antigen = list(pick(ALL_ANTIGENS))
	antigen |= pick(ALL_ANTIGENS)
	if(prob(70))
		set_legacy_spreadtype("Airborne")
	else
		set_legacy_spreadtype("Contact")

	if(all_species.len)
		affected_species = get_infectable_species()
	sync_knowledge_from_model()
	update_disease()

/datum/disease2/disease/proc/rebuild_effects_from_strain()
	if(!model_managed || !strain)
		return
	for(var/datum/disease2/effect/E in effects)
		if(infected)
			E.deactivate(infected)
		effects -= E
		qdel(E)
	for(var/list/blueprint in strain.phenotype_blueprints)
		var/effect_type = blueprint["effect_type"]
		if(!effect_type)
			continue
		if(!can_add_symptom(effect_type))
			continue
		var/datum/disease2/effect/new_effect = new effect_type
		new_effect.stage = blueprint["stage"]
		new_effect.chance = blueprint["chance"]
		new_effect.multiplier = blueprint["multiplier"]
		effects += new_effect

/datum/disease2/disease/proc/sync_knowledge_from_model()
	if(!knowledge)
		knowledge = new
	knowledge.knowledge_level = 0
	if(strain)
		knowledge.confirm_hypothesis("Genome signature [strain.get_genome_signature()]")
	knowledge.confirm_hypothesis("Transmission route [transmission_mode_to_text()]")
	if(antigen && antigen.len)
		knowledge.prove_vulnerability("Antigen docking: [antigens2string(antigen)]")
	if(affected_species && affected_species.len)
		knowledge.prove_vulnerability("Host range constrained to [jointext(affected_species, \", \")]")
	if(knowledge.proven_vulnerabilities.len >= 2)
		knowledge.knowledge_level = 3

/datum/disease2/disease/proc/sync_knowledge_from_effects()
	if(!knowledge)
		knowledge = new
	knowledge.knowledge_level = 1
	if(effects.len)
		knowledge.confirm_hypothesis("Phenotype observed: [effects.len] symptom(s)")
	if(antigen && antigen.len)
		knowledge.prove_vulnerability("Antigen docking: [antigens2string(antigen)]")

/proc/get_infectable_species()
	var/list/meat = list()
	var/list/res = list()
	for (var/specie in all_species)
		var/datum/species/S = all_species[specie]
		if((S.spawn_flags & SPECIES_CAN_JOIN) && !S.get_virus_immune() && !S.greater_form)
			meat += S
	if(meat.len)
		var/num = rand(1, meat.len)
		for(var/i = 0, i<num, i++)
			var/datum/species/picked = pick_n_take(meat)
			res |= picked.name
			if(picked.primitive_form)
				res |= picked.primitive_form
	return res

/datum/disease2/disease/proc/process()
	if(!infected)
		return

	if(dead)
		cure()
		return

	if(infected.is_ic_dead())
		return

	if(stage <= 1 && clicks == 0) 	// with a certain chance, the mob may become immune to the disease before it starts properly
		if(prob(infected.virus_immunity() * 0.05))
			cure()
			return

	// Some species are flat out immune to organic viruses.
	if(infected.species.get_virus_immune(infected))
		cure()
		return

	if(infected.radiation > (0.1 SIEVERT))
		if(prob(4))
			majormutate()

	if(prob(infected.virus_immunity()) && prob(stage)) // Increasing chance of curing as the virus progresses
		cure()
	//Waiting out the disease the old way
	if(stage == max_stage && clicks > max(stage * 100, 300))
		if(prob(infected.virus_immunity() * 0.05 + 100 - infectionchance))
			cure()

	var/top_badness = 1
	for(var/datum/disease2/effect/e in effects)
		if(e.stage == stage)
			top_badness = max(top_badness, e.badness)

	//Space antibiotics might stop disease completely
	if(infected.chem_effects[CE_ANTIVIRAL] > top_badness)
		if(stage == 1 && prob(20))
			cure()
		return

	clicks += speed
	//Virus food speeds up disease progress
	if(infected.reagents.has_reagent(/datum/reagent/nutriment/virus_food))
		infected.reagents.remove_reagent(/datum/reagent/nutriment/virus_food, REM)
		clicks += 10

	//Moving to the next stage
	if(clicks > max(stage * 100, 300))
		if(stage < max_stage && prob(10))
			stage++
			clicks = 0

	//Do nasty effects
	for(var/datum/disease2/effect/e in effects)
		e.fire(stage)

	//fever
	if(!infected.chem_effects[CE_ANTIVIRAL])
		infected.bodytemperature = max(infected.bodytemperature, min(310 + 5 * min(stage, max_stage), infected.bodytemperature + 5 * min(stage, max_stage)))

/datum/disease2/disease/proc/cure()
	ASSERT(infected) //You can't cure disease if there's no diseased

	SSvirus.dequeue_virus(src)
	for(var/datum/disease2/effect/e in effects)
		e.deactivate(infected)
	infected.virus2.Remove("[uniqueID]")
	if(antigen)
		infected.antibodies |= antigen

	BITSET(infected.hud_updateflag, STATUS_HUD)

/datum/disease2/disease/proc/minormutate()
	if(model_managed && strain)
		strain.mutate_minor()
		update_disease()
		return
	var/datum/disease2/effect/E = pick(effects)
	if(E)
		E.minormutate()

/datum/disease2/disease/proc/mediummutate()
	if(model_managed && strain)
		strain.mutate_medium()
		update_disease()
		return 1
	var/list/datum/disease2/effect/mutable_effects = list()
	for(var/datum/disease2/effect/T in effects)
		if(T.possible_mutations && T.possible_mutations.len)
			mutable_effects += T
	if(!mutable_effects.len)
		return 0

	uniqueID = rand(0,10000)
	var/datum/disease2/effect/mutating_effect = pick(mutable_effects)
	var/list/exclude = list()
	for(var/datum/disease2/effect/D in effects)
		if(D != mutating_effect)
			exclude += D.type
	var/datum/disease2/effect/new_effect = get_mutated_effect(mutating_effect)
	if(!new_effect)
		return 0
	if(infected)
		mutating_effect.deactivate(infected)
	effects -= mutating_effect
	effects += new_effect
	update_disease()
	qdel(mutating_effect)
	return 1

/datum/disease2/disease/proc/majormutate(badness = VIRUS_ENGINEERED)
	if(model_managed && strain)
		strain.mutate_major()
		if(prob(5))
			antigen = list(pick(ALL_ANTIGENS))
			antigen |= pick(ALL_ANTIGENS)
		if(prob(5) && all_species.len)
			affected_species = get_infectable_species()
		update_disease()
		return
	uniqueID = rand(0,10000)
	var/datum/disease2/effect/E = pick(effects)
	var/list/exclude = list()
	for(var/datum/disease2/effect/D in effects)
		if(D != E)
			exclude += D.type
	var/effect_stage = E.stage
	if(infected)
		E.deactivate(infected)
	effects -= E
	qdel(E)

	effects += get_random_virus2_effect(effect_stage, badness, exclude)

	if(prob(5))
		antigen = list(pick(ALL_ANTIGENS))
		antigen |= pick(ALL_ANTIGENS)

	if(prob(5) && all_species.len)
		affected_species = get_infectable_species()
	update_disease()

/datum/disease2/disease/proc/stageshift()
	if(model_managed)
		for(var/list/blueprint in strain.phenotype_blueprints)
			blueprint["stage"] = min(max_stage, blueprint["stage"] + 1)
		update_disease()
		return
	uniqueID = rand(0, 10000)
	var/list/exclude = list()
	for(var/datum/disease2/effect/D in effects)
		if(!D.stage == 1 || !D.stage == max_stage)
			exclude += D.type
		D.stage += 1
		if(D.stage > max_stage)
			effects -= D
	effects += get_random_virus2_effect(1, VIRUS_MILD, exclude)
	update_disease()

/datum/disease2/disease/proc/getcopy()
	var/datum/disease2/disease/disease = new /datum/disease2/disease
	disease.infectionchance = infectionchance
	disease.spreadtype = spreadtype
	disease.transmission_mode = transmission_mode.Copy()
	disease.speed = speed
	disease.antigen   = antigen
	disease.uniqueID = uniqueID
	disease.model_managed = model_managed
	disease.affected_species = affected_species.Copy()
	if(model_managed && strain)
		disease.strain.segments = list()
		for(var/datum/pathogen_genome_segment/segment in strain.segments)
			var/datum/pathogen_genome_segment/new_segment = new
			new_segment.slot = segment.slot
			new_segment.allele = segment.allele
			new_segment.expression = segment.expression
			disease.strain.segments += new_segment
		disease.strain.regulators = list()
		for(var/datum/pathogen_regulator/regulator in strain.regulators)
			var/datum/pathogen_regulator/new_regulator = new
			new_regulator.id = regulator.id
			new_regulator.target_trait = regulator.target_trait
			new_regulator.modifier = regulator.modifier
			disease.strain.regulators += new_regulator
		disease.strain.Infectivity = strain.Infectivity
		disease.strain.Shedding = strain.Shedding
		disease.strain.Stealth = strain.Stealth
		disease.strain.Latency = strain.Latency
		disease.strain.StageSpeed = strain.StageSpeed
		disease.strain.Severity = strain.Severity
		disease.strain.Resistance = strain.Resistance
		disease.strain.Stability = strain.Stability
		disease.strain.MutationRate = strain.MutationRate
		disease.strain.Recombination = strain.Recombination
		disease.strain.TransmissionMode = strain.TransmissionMode ? strain.TransmissionMode.Copy() : list()
		disease.strain.recompute_phenotype()
	for(var/datum/disease2/effect/effect in effects)
		var/datum/disease2/effect/neweffect = new effect.type
		neweffect.generate(effect.data)
		neweffect.chance = effect.chance
		neweffect.multiplier = effect.multiplier
		neweffect.stage = effect.stage
		disease.effects += neweffect
	if(model_managed)
		disease.rebuild_effects_from_strain()
	disease.update_disease()
	return disease

/datum/disease2/disease/proc/issame(datum/disease2/disease/disease)
	. = 1

	var/list/types = list()
	for(var/datum/disease2/effect/d in effects)
		types += d.type
	for(var/datum/disease2/effect/d in disease.effects)
		if(!(d.type in types))
			return 0

	if(antigen != disease.antigen)
		return 0

/proc/virus_copylist(list/datum/disease2/disease/viruses)
	var/list/res = list()
	for (var/ID in viruses)
		var/datum/disease2/disease/V = viruses[ID]
		res["[V.uniqueID]"] = V.getcopy()
	return res


var/global/list/virusDB = list()

/datum/disease2/disease/proc/name()
	.= "strain #[add_zero("[uniqueID]", 4)]"
	if ("[uniqueID]" in virusDB)
		var/datum/computer_file/data/virus_record/V = virusDB["[uniqueID]"]
		.= V.fields["name"]

/datum/disease2/disease/proc/get_basic_info()
	var/list/symptoms = list()
	for(var/datum/disease2/effect/E in effects)
		symptoms += E.name
	var/symptom_text = symptoms.len ? jointext(symptoms, ", ") : "No active phenotype"
	return "[name()] ([symptom_text])"

/datum/disease2/disease/proc/get_info()
	var/knowledge_label = knowledge ? knowledge.get_level_label() : "Level 0 - Unknown"
	var/species_text = affected_species && affected_species.len ? jointext(affected_species, ", ") : "Unknown"
	var/r = {"
	<small>Analysis determined the existence of a GNAv2-based viral lifeform.</small><br>
	<u>Designation:</u> [name()]<br>
	<u>Knowledge:</u> [knowledge_label]<br>
	<u>Antigen:</u> [antigens2string(antigen)]<br>
	<u>Transmitted By:</u> [transmission_mode_to_text()]<br>
	<u>Rate of Progression:</u> [speed * 100]%<br>
	<u>Species Affected:</u> [species_text]<br>
"}
	if(strain && strain.metadata && strain.metadata["genome_signature"])
		r += "<u>Genome Signature:</u> [strain.metadata[\"genome_signature\"]]<br>"
	var/hypothesis_text = (knowledge && knowledge.confirmed_hypotheses.len) ? jointext(knowledge.confirmed_hypotheses, "; ") : "none"
	var/vulnerability_text = (knowledge && knowledge.proven_vulnerabilities.len) ? jointext(knowledge.proven_vulnerabilities, "; ") : "none"
	r += "<u>Confirmed Hypotheses:</u> [hypothesis_text]<br>"
	r += "<u>Proven Vulnerabilities:</u> [vulnerability_text]<br>"

	r += "<u>Symptoms:</u><br>"
	for(var/datum/disease2/effect/E in effects)
		r += "([E.stage]) [E.name]    "
		r += "<small><u>Strength:</u> [E.multiplier >= 3 ? \"Severe\" : E.multiplier > 1 ? \"Above Average\" : \"Average\"]    "
		r += "<u>Verosity:</u> [E.chance * 15]</small><br>"

	return r

/datum/disease2/disease/proc/addToDB()
	if("[uniqueID]" in virusDB)
		return 0
	var/datum/computer_file/data/virus_record/v = new()
	v.fields["id"] = uniqueID
	v.fields["name"] = name()
	v.fields["description"] = get_info()
	v.fields["antigen"] = antigens2string(antigen)
	v.fields["spread type"] = transmission_mode_to_text()
	virusDB["[uniqueID]"] = v
	return 1

/datum/disease2/disease/proc/set_legacy_spreadtype(mode)
	if(mode == "Airborne")
		transmission_mode = list("airborne" = 1, "contact" = 0.2, "blood" = 0)
	else
		transmission_mode = list("airborne" = 0.05, "contact" = 1, "blood" = 1)
	if(model_managed && strain)
		strain.TransmissionMode = transmission_mode.Copy()
	spreadtype = derive_legacy_spreadtype()

/datum/disease2/disease/proc/get_transmission_weight(channel)
	if(!transmission_mode)
		return 0
	channel = lowertext(channel)
	return clamp(transmission_mode[channel] || 0, 0, 1)

/datum/disease2/disease/proc/supports_transmission_channel(channel, min_weight = 0.15)
	return get_transmission_weight(channel) >= min_weight

/datum/disease2/disease/proc/derive_legacy_spreadtype()
	return get_transmission_weight("airborne") >= get_transmission_weight("contact") ? "Airborne" : "Contact"

/datum/disease2/disease/proc/transmission_mode_to_text()
	if(!transmission_mode || !transmission_mode.len)
		return "Unknown"
	var/list/channels = list()
	for(var/channel in transmission_mode)
		var/weight = round((transmission_mode[channel] || 0) * 100)
		if(weight <= 0)
			continue
		channels += "[uppertext(copytext(channel, 1, 2))][copytext(channel, 2)]([weight]%)"
	if(!channels.len)
		return "None"
	return jointext(channels, ", ")


/proc/virology_letterhead(report_name)
	return {"
		<center><h1><b>[report_name]</b></h1></center>
		<center><small><i>[station_name()] Virology Lab</i></small></center>
		<hr>
"}

/datum/disease2/disease/proc/can_add_symptom(type)
	for(var/datum/disease2/effect/H in effects)
		if(H.type == type && !H.allow_multiple)
			return 0
	return 1
