// Antigenic signature and antibody helpers.

var/global/list/ANTIGENIC_EPITOPES = list("A", "B", "C", "D", "E", "F", "G", "H")
var/global/list/ANTIGENIC_VARIANTS = list("1", "2", "3", "4")

/proc/random_antigenic_signature(min_epitopes = 2, max_epitopes = 4)
	var/list/signature = list()
	var/list/available_epitopes = ANTIGENIC_EPITOPES.Copy()
	var/target_count = clamp(rand(min_epitopes, max_epitopes), min_epitopes, min(max_epitopes, available_epitopes.len))
	for(var/i in 1 to target_count)
		var/epitope = pick_n_take(available_epitopes)
		signature[epitope] = pick(ANTIGENIC_VARIANTS)
	return signature

/proc/normalize_antibody_map(list/raw)
	var/list/normalized = list()
	if(!islist(raw))
		return normalized

	for(var/entry in raw)
		if(islist(raw[entry]))
			var/list/variant_pool = raw[entry]
			for(var/variant in variant_pool)
				antibody_map_add_variant(normalized, "[entry]", "[variant]")
			continue

		if(!isnull(raw[entry]))
			var/value = raw[entry]
			if(length("[entry]") == 1)
				antibody_map_add_variant(normalized, "[entry]", "[value]")
			continue

		var/token = "[entry]"
		var/separator = findtext(token, ":")
		if(separator)
			var/epitope = copytext(token, 1, separator)
			var/variant = copytext(token, separator + 1)
			antibody_map_add_variant(normalized, epitope, variant)
		else
			// Legacy single-letter antigen format.
			antibody_map_add_variant(normalized, token, "1")

	return normalized

/proc/antibody_map_add_variant(list/antibody_map, epitope, variant)
	if(!epitope)
		return
	if(!variant)
		variant = "1"
	if(!islist(antibody_map[epitope]))
		antibody_map[epitope] = list()
	var/list/variants = antibody_map[epitope]
	variants |= "[variant]"

/proc/merge_antibody_maps(list/base, list/incoming)
	var/list/normalized_base = normalize_antibody_map(base)
	var/list/normalized_incoming = normalize_antibody_map(incoming)
	for(var/epitope in normalized_incoming)
		var/list/variants = normalized_incoming[epitope]
		for(var/variant in variants)
			antibody_map_add_variant(normalized_base, epitope, variant)
	return normalized_base

/proc/antibodies_match_signature(list/antibody_map, list/signature)
	var/list/normalized_antibodies = normalize_antibody_map(antibody_map)
	var/list/normalized_signature = normalize_antibody_map(signature)
	for(var/epitope in normalized_signature)
		var/variant = "[normalized_signature[epitope]]"
		var/list/known_variants = normalized_antibodies[epitope]
		if(!islist(known_variants))
			continue
		if((variant in known_variants) || ("*" in known_variants))
			return TRUE
	return FALSE

/proc/flatten_antibody_map(list/antibody_map)
	var/list/flattened = list()
	var/list/normalized = normalize_antibody_map(antibody_map)
	for(var/epitope in normalized)
		var/list/variants = normalized[epitope]
		for(var/variant in variants)
			flattened |= "[epitope]:[variant]"
	return flattened

/proc/antigenic_signature_to_string(list/signature, none = "None")
	var/list/normalized = normalize_antibody_map(signature)
	if(!normalized.len)
		return none
	var/list/chunks = list()
	for(var/epitope in ANTIGENIC_EPITOPES)
		if(!(epitope in normalized))
			continue
		var/list/variants = normalized[epitope]
		if(!variants || !variants.len)
			continue
		chunks += "[epitope]-[jointext(variants, "/")]"
	if(!chunks.len)
		for(var/epitope in normalized)
			var/list/variants = normalized[epitope]
			chunks += "[epitope]-[jointext(variants, "/")]"
	return chunks.len ? jointext(chunks, ", ") : none

/proc/antigens2string(list/antigens, none = "None")
	ASSERT(antigens)
	return antigenic_signature_to_string(antigens, none)
