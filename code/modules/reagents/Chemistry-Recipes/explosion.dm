
/* Explosion reactions */

/datum/chemical_reaction/explosion
	name = "Explosion"
	mix_message = null
	result_amount = 2
	log_is_important = 1

/datum/chemical_reaction/explosion/on_reaction(datum/reagents/holder, created_volume)
	var/datum/effect/effect/system/reagents_explosion/e = new()
	e.set_up(created_volume * 0.25, holder.my_atom, 0, 0)
	e.start()
	holder.clear_reagents()


/datum/chemical_reaction/explosion/potassium
	required_reagents = list(/datum/reagent/water = 1, /datum/reagent/potassium = 1)
	result_amount = 1.5

/datum/chemical_reaction/explosion/hair_solution
	required_reagents = list(/datum/reagent/toxin/hair_grower = 1, /datum/reagent/toxin/hair_remover = 1)
	result_amount = 1


/datum/chemical_reaction/explosion/nitroglycerin
	name = "Nitroglycerin"
	// will be deleted in on_reaction, anyways
	// result = /datum/reagent/Nitroglycerin
	required_reagents = list(/datum/reagent/glycerol = 1, /datum/reagent/acid/polyacid = 1, /datum/reagent/acid = 1)
	result_amount = 3
