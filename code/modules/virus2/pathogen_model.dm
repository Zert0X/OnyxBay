/datum/pathogen_profile
	var/name = "Generic GNAv2 agent"
	var/biology = "GNAv2"
	var/list/species_targets = list(SPECIES_HUMAN, SPECIES_UNATHI, SPECIES_SKRELL, SPECIES_TAJARA, SPECIES_SWINE)
	var/list/treatment_limitations = list("Requires antigen-matched antiviral support")

/datum/pathogen_knowledge
	var/knowledge_level = 0 // 0-3
	var/list/confirmed_hypotheses = list()
	var/list/proven_vulnerabilities = list()

/datum/pathogen_knowledge/proc/confirm_hypothesis(text)
	if(!text)
		return
	confirmed_hypotheses |= text
	knowledge_level = min(3, max(knowledge_level, 1))

/datum/pathogen_knowledge/proc/prove_vulnerability(text)
	if(!text)
		return
	proven_vulnerabilities |= text
	knowledge_level = min(3, max(knowledge_level, 2))

/datum/pathogen_knowledge/proc/get_level_label()
	switch(knowledge_level)
		if(0)
			return "Level 0 - Unknown"
		if(1)
			return "Level 1 - Hypothesis"
		if(2)
			return "Level 2 - Confirmed"
		if(3)
			return "Level 3 - Exhaustive"
	return "Level ?"

/datum/pathogen_culture
	var/growth_index = 1.0
	var/heterogeneity = 0.0
	var/contamination = 0.0
	var/BiohazardLevel = 0
	var/list/pressure_history = list()

/datum/pathogen_culture/proc/apply_pressure(pressure_label, delta_growth = 0, delta_heterogeneity = 0, delta_contamination = 0, pressure_kpa = null)
	if(!pressure_label)
		return
	pressure_history += "[world.time]: [pressure_label]"

	var/adjusted_growth = delta_growth
	if(is_dangerous_pressure(pressure_label, pressure_kpa) && delta_growth > 0)
		adjusted_growth *= get_danger_pressure_growth_multiplier(pressure_kpa)

	growth_index = max(0.2, growth_index + adjusted_growth)
	heterogeneity = clamp(heterogeneity + delta_heterogeneity, 0, 1)
	contamination = clamp(contamination + delta_contamination, 0, 1)
	recalculate_biohazard_level(pressure_label, pressure_kpa)

/datum/pathogen_culture/proc/is_dangerous_pressure(pressure_label, pressure_kpa)
	if(isnum(pressure_kpa) && pressure_kpa >= (ONE_ATMOSPHERE * 1.8))
		return TRUE

	if(findtext(lowertext("[pressure_label]"), "danger") || findtext(lowertext("[pressure_label]"), "hazard") || findtext(lowertext("[pressure_label]"), "critical"))
		return TRUE

	return FALSE

/datum/pathogen_culture/proc/get_danger_pressure_growth_multiplier(pressure_kpa)
	if(!isnum(pressure_kpa))
		return 1.6

	var/normalized_pressure = clamp((pressure_kpa - (ONE_ATMOSPHERE * 1.8)) / (ONE_ATMOSPHERE * 2.2), 0, 2)
	return 1 + (normalized_pressure ** 2) * 1.5

/datum/pathogen_culture/proc/recalculate_biohazard_level(pressure_label, pressure_kpa)
	var/danger_bonus = is_dangerous_pressure(pressure_label, pressure_kpa) ? 0.75 : 0
	var/hazard_score = (growth_index * 0.5) + (heterogeneity * 2) + (contamination * 2.5) + danger_bonus
	BiohazardLevel = clamp(round(hazard_score), 0, 5)

/datum/pathogen_genome_segment
	var/slot = 1
	var/allele = "A"
	var/expression = 1

/datum/pathogen_regulator
	var/id = "R1"
	var/target_trait = "respiratory"
	var/modifier = 1

/datum/pathogen_strain
	var/strain_id = 0
	var/Infectivity = 1
	var/Shedding = 1
	var/Stealth = 1
	var/Latency = 1
	var/StageSpeed = 1
	var/Severity = 1
	var/Resistance = 1
	var/Stability = 1
	var/MutationRate = 1
	var/Recombination = 1
	var/list/TransmissionMode = list("airborne" = 0.5, "contact" = 0.5, "blood" = 0.2)
	var/list/datum/pathogen_genome_segment/segments = list()
	var/list/datum/pathogen_regulator/regulators = list()
	var/list/phenotype_blueprints = list()
	var/list/metadata = list()
	var/list/AntigenicSignature = list()

/datum/pathogen_strain/New()
	..()
	strain_id = rand(0, 10000)

/datum/pathogen_strain/proc/initialize_random()
	Infectivity = rand(50, 160) / 100
	Shedding = rand(50, 160) / 100
	Stealth = rand(50, 160) / 100
	Latency = rand(50, 160) / 100
	StageSpeed = rand(50, 160) / 100
	Severity = rand(50, 160) / 100
	Resistance = rand(50, 160) / 100
	Stability = rand(50, 160) / 100
	MutationRate = rand(50, 160) / 100
	Recombination = rand(50, 160) / 100
	TransmissionMode = list(
		"airborne" = rand(10, 100) / 100,
		"contact" = rand(10, 100) / 100,
		"blood" = rand(10, 100) / 100
	)
	segments = list()
	regulators = list()
	var/segment_count = rand(6, 10)
	for(var/i in 1 to segment_count)
		var/datum/pathogen_genome_segment/segment = new
		segment.slot = i
		segment.allele = pick("A", "B", "C", "D", "E", "F")
		segment.expression = rand(50, 150) / 100
		segments += segment
	var/regulator_count = rand(3, 6)
	for(var/r in 1 to regulator_count)
		var/datum/pathogen_regulator/regulator = new
		regulator.id = "R[r]"
		regulator.target_trait = pick("respiratory", "neurological", "digestive", "systemic")
		regulator.modifier = rand(70, 140) / 100
		regulators += regulator
	AntigenicSignature = random_antigenic_signature()
	recompute_phenotype()

/datum/pathogen_strain/proc/get_trait_signal(target_trait)
	var/signal = 0
	for(var/datum/pathogen_genome_segment/segment in segments)
		var/list/trait_map = pathogen_allele_traits(segment.allele)
		signal += (trait_map[target_trait] || 0) * segment.expression
	for(var/datum/pathogen_regulator/regulator in regulators)
		if(regulator.target_trait == target_trait)
			signal *= regulator.modifier
	return signal

/datum/pathogen_strain/proc/recompute_phenotype()
	phenotype_blueprints = list()
	var/list/rules = pathogen_effect_predicates()
	for(var/list/rule in rules)
		var/trait = rule["trait"]
		if(get_trait_signal(trait) < rule["threshold"])
			continue
		var/list/blueprint = list(
			"effect_type" = rule["effect_type"],
			"stage" = rule["stage"],
			"chance" = rule["chance"],
			"multiplier" = rule["multiplier"]
		)
		phenotype_blueprints += list(blueprint)
	metadata["genome_signature"] = get_genome_signature()

/datum/pathogen_strain/proc/get_genome_signature()
	var/list/signature = list()
	for(var/datum/pathogen_genome_segment/segment in segments)
		signature += "[segment.slot]:[segment.allele]-[segment.expression]"
	for(var/datum/pathogen_regulator/regulator in regulators)
		signature += "[regulator.id]:[regulator.target_trait]-[regulator.modifier]"
	return jointext(signature, "|")

/datum/pathogen_strain/proc/mutate_minor()
	if(!segments.len)
		return
	var/datum/pathogen_genome_segment/segment = pick(segments)
	segment.expression = clamp(segment.expression + rand(-20, 20) / 100, 0.4, 1.8)
	recompute_phenotype()

/datum/pathogen_strain/proc/mutate_medium()
	if(!segments.len)
		return
	var/datum/pathogen_genome_segment/segment = pick(segments)
	segment.allele = pick("A", "B", "C", "D", "E", "F")
	recompute_phenotype()

/datum/pathogen_strain/proc/mutate_major()
	if(!regulators.len)
		return
	var/datum/pathogen_regulator/regulator = pick(regulators)
	regulator.target_trait = pick("respiratory", "neurological", "digestive", "systemic")
	regulator.modifier = rand(60, 170) / 100
	recompute_phenotype()

/proc/pathogen_allele_traits(allele)
	switch(allele)
		if("A")
			return list("respiratory" = 1.2, "systemic" = 0.6)
		if("B")
			return list("digestive" = 1.1, "systemic" = 0.4)
		if("C")
			return list("neurological" = 1.3, "systemic" = 0.5)
		if("D")
			return list("respiratory" = 0.6, "digestive" = 0.9)
		if("E")
			return list("systemic" = 1.4)
		if("F")
			return list("neurological" = 0.7, "respiratory" = 0.7, "digestive" = 0.7)
	return list()

/proc/pathogen_effect_predicates()
	return list(
		list("effect_type" = /datum/disease2/effect/sneeze, "trait" = "respiratory", "threshold" = 2.2, "stage" = 1, "chance" = 35, "multiplier" = 1),
		list("effect_type" = /datum/disease2/effect/cough, "trait" = "respiratory", "threshold" = 3.0, "stage" = 2, "chance" = 45, "multiplier" = 1),
		list("effect_type" = /datum/disease2/effect/headache, "trait" = "neurological", "threshold" = 2.3, "stage" = 2, "chance" = 35, "multiplier" = 1),
		list("effect_type" = /datum/disease2/effect/confusion, "trait" = "neurological", "threshold" = 3.1, "stage" = 3, "chance" = 30, "multiplier" = 2),
		list("effect_type" = /datum/disease2/effect/stomach, "trait" = "digestive", "threshold" = 2.2, "stage" = 2, "chance" = 30, "multiplier" = 1),
		list("effect_type" = /datum/disease2/effect/hungry, "trait" = "digestive", "threshold" = 3.0, "stage" = 3, "chance" = 35, "multiplier" = 2),
		list("effect_type" = /datum/disease2/effect/drowsness, "trait" = "systemic", "threshold" = 2.0, "stage" = 1, "chance" = 45, "multiplier" = 1),
		list("effect_type" = /datum/disease2/effect/shakey, "trait" = "systemic", "threshold" = 3.2, "stage" = 4, "chance" = 25, "multiplier" = 2)
	)
