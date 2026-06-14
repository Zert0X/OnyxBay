
/* what this does:
catalogue the 'taste strength' of each one
calculate text size per text.
*/
/datum/reagents/proc/generate_taste_message(mob/living/carbon/taster = null)
	var/minimum_percent = 15
	if(ishuman(taster))
		var/mob/living/carbon/human/H = taster

		var/dull_taste = FALSE
		if(H.should_have_organ(BP_TONGUE))
			var/obj/item/organ/internal/tongue/L = taster.internal_organs_by_name[BP_TONGUE]
			if(L?.is_bruised())
				dull_taste = TRUE
		if(H.isSynthetic())
			dull_taste = TRUE

		minimum_percent = round(15/ (dull_taste ? TASTE_DULL : H.species.taste_sensitivity))

	var/list/out = list()
	var/list/tastes = list() //descriptor = strength
	if(minimum_percent <= 100)
		for(var/datum/reagent/R in reagent_list)
			if(!R.taste_mult)
				continue
			if(R.type == /datum/reagent/nutriment) //this is ugly but apparently only nutriment (not subtypes) has taste data TODO figure out why
				var/list/taste_data = R.get_data()
				var/nutriment_amount = get_reagent_amount(R.type)
				for(var/taste in taste_data)
					if(taste in tastes)
						tastes[taste] += nutriment_amount * taste_data[taste]
					else
						tastes[taste] = nutriment_amount * taste_data[taste]
			else
				var/taste_desc = R.taste_description
				var/taste_amount = get_reagent_amount(R.type) * R.taste_mult
				if(R.taste_description in tastes)
					tastes[taste_desc] += taste_amount
				else
					tastes[taste_desc] = taste_amount

		//deal with percentages
		var/total_taste = 0
		for(var/taste_desc in tastes)
			total_taste += tastes[taste_desc]
		for(var/taste_desc in tastes)
			var/percent = tastes[taste_desc]/total_taste * 100
			if(percent < minimum_percent)
				continue
			var/intensity_desc = "a hint of"
			if(percent > minimum_percent * 2 || percent == 100)
				intensity_desc = ""
			else if(percent > minimum_percent * 3)
				intensity_desc = "the strong flavor of"
			if(intensity_desc == "")
				out += "[taste_desc]"
			else
				out += "[intensity_desc] [taste_desc]"

	return english_list(out, "something indescribable")

/mob/living/carbon/proc/get_fullness()
	return nutrition + (reagents.get_reagent_amount(/datum/reagent/nutriment) * 10)
