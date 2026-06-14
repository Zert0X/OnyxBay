
/* Metroid cores */

/datum/chemical_reaction/metroid
	var/required = null

/datum/chemical_reaction/metroid/can_happen(datum/reagents/holder)
	if(holder.my_atom && istype(holder.my_atom, required))
		var/obj/item/metroid_extract/T = holder.my_atom
		if(T.Uses > 0)
			return ..()
	return 0

/datum/chemical_reaction/metroid/on_reaction(datum/reagents/holder)
	var/obj/item/metroid_extract/T = holder.my_atom
	T.Uses--
	if(T.Uses <= 0)
		T.visible_message("\icon[T]<span class='notice'>\The [T]'s power is consumed in the reaction.</span>")
		T.SetName("used metroid extract")
		T.desc = "This extract has been used up."

//Green
/datum/chemical_reaction/metroid/create
	name = "Metroid Spawn"
	result = null
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	result_amount = 1
	required = /obj/item/metroid_extract/green

/datum/chemical_reaction/metroid/create/on_reaction(datum/reagents/holder)
	holder.my_atom.visible_message("<span class='warning'>Infused with plasma, the core begins to quiver and grow, and soon a new baby metroid emerges from it!</span>")
	var/mob/living/carbon/metroid/S = new /mob/living/carbon/metroid
	S.forceMove(get_turf(holder.my_atom))
	..()

/datum/chemical_reaction/metroid/monkey
	name = "Metroid Monkey"
	result = null
	required_reagents = list(/datum/reagent/blood = 1)
	result_amount = 1
	required = /obj/item/metroid_extract/green

/datum/chemical_reaction/metroid/monkey/on_reaction(datum/reagents/holder)
	for(var/i = 1, i <= 3, i++)
		var /obj/item/reagent_containers/food/monkeycube/M = new /obj/item/reagent_containers/food/monkeycube
		M.forceMove(get_turf(holder.my_atom))
	..()

/datum/chemical_reaction/metroid/heal
	name = "Metroid heal"
	result = /datum/reagent/tricordrazine
	required_reagents = list(/datum/reagent/water = 1)
	result_amount = 15
	required = /obj/item/metroid_extract/green

//Grey
/datum/chemical_reaction/metroid/mutate
	name = "Mutation Toxin"
	result = /datum/reagent/metroidtoxin
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	result_amount = 1
	required = /obj/item/metroid_extract/grey

//Metal
/datum/chemical_reaction/metroid/metal
	name = "Metroid Metal"
	result = null
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	result_amount = 1
	required = /obj/item/metroid_extract/metal

/datum/chemical_reaction/metroid/metal/on_reaction(datum/reagents/holder)
	var/obj/item/stack/material/steel/M = new /obj/item/stack/material/steel
	M.amount = 15
	M.forceMove(get_turf(holder.my_atom))
	var/obj/item/stack/material/plasteel/P = new /obj/item/stack/material/plasteel
	P.amount = 5
	P.forceMove(get_turf(holder.my_atom))
	..()

/datum/chemical_reaction/metroid/glass
	name = "Metroid Glass"
	result = null
	required_reagents = list(/datum/reagent/water = 1)
	result_amount = 1
	required = /obj/item/metroid_extract/metal

/datum/chemical_reaction/metroid/glass/on_reaction(datum/reagents/holder)
	var/obj/item/stack/material/glass/M = new /obj/item/stack/material/glass
	M.amount = 15
	M.forceMove(get_turf(holder.my_atom))
	var/obj/item/stack/material/glass/reinforced/P = new /obj/item/stack/material/glass/reinforced
	P.amount = 5
	P.forceMove(get_turf(holder.my_atom))
	..()

/datum/chemical_reaction/metroid/marble
	name = "Metroid marble"
	result = null
	required_reagents = list(/datum/reagent/blood = 1)
	result_amount = 1
	required = /obj/item/metroid_extract/metal

/datum/chemical_reaction/metroid/marble/on_reaction(datum/reagents/holder)
	var/obj/item/stack/material/marble/M = new /obj/item/stack/material/marble
	M.amount = 30
	M.forceMove(get_turf(holder.my_atom))
	..()

//Gold
/datum/chemical_reaction/metroid/f_crit
	name = "Metroid Friendly Crit"
	result = null
	required_reagents = list(/datum/reagent/water = 1)
	result_amount = 1
	required = /obj/item/metroid_extract/gold
	var/list/possible_mobs = list(
							/mob/living/simple_animal/cat,
							/mob/living/simple_animal/cat/kitten,
							/mob/living/simple_animal/corgi,
							/mob/living/simple_animal/corgi/puppy,
							/mob/living/simple_animal/cow,
							/mob/living/simple_animal/chick,
							/mob/living/simple_animal/chicken
							)

/datum/chemical_reaction/metroid/f_crit/on_reaction(datum/reagents/holder)
	var/type = pick(possible_mobs)
	new type(get_turf(holder.my_atom))
	..()

/datum/chemical_reaction/metroid/n_crit
	name = "Metroid Neutral Crit"
	result = null
	required_reagents = list(/datum/reagent/blood = 1)
	result_amount = 1
	required = /obj/item/metroid_extract/gold
	var/list/possible_mobs = list(
							/mob/living/simple_animal/hostile/asteroid/goliath,
							/mob/living/simple_animal/hostile/asteroid/sand_lurker,
							/mob/living/simple_animal/hostile/asteroid/shooter,
							/mob/living/simple_animal/hostile/asteroid/hoverhead
							)

/datum/chemical_reaction/metroid/n_crit/on_reaction(datum/reagents/holder)
	..()
	for(var/i = 1, i <= 3, i++)
		var/mob/living/simple_animal/hostile/asteroid/type = pick(possible_mobs)
		new type(get_turf(holder.my_atom))
		type.faction = "neutral"

/datum/chemical_reaction/metroid/d_crit
	name = "Metroid Dangerous Crit"
	result = null
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	result_amount = 1
	required = /obj/item/metroid_extract/gold
	var/list/possible_mobs = list(
							/mob/living/simple_animal/hostile/faithless,
							/mob/living/simple_animal/hostile/creature,
							/mob/living/simple_animal/hostile/bear,
							/mob/living/simple_animal/hostile/maneater,
							/mob/living/simple_animal/hostile/mimic,
							/mob/living/simple_animal/hostile/carp/pike,
							/mob/living/simple_animal/hostile/tree,
							/mob/living/simple_animal/hostile/vagrant,
							/mob/living/simple_animal/hostile/voxslug
							)

/datum/chemical_reaction/metroid/d_crit/on_reaction(datum/reagents/holder)
	for(var/i = 1, i <= 5, i++)
		var/type = pick(possible_mobs)
		new type(get_turf(holder.my_atom))
	..()

//Silver
/datum/chemical_reaction/metroid/bork
	name = "Metroid Bork"
	result = null
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	result_amount = 1
	required = /obj/item/metroid_extract/silver

/datum/chemical_reaction/metroid/bork/on_reaction(datum/reagents/holder)
	var/list/borks = typesof(/obj/item/reagent_containers/food) - /obj/item/reagent_containers/food
	playsound(holder.my_atom, 'sound/effects/phasein.ogg', 100, 1)
	for(var/mob/living/carbon/human/M in viewers(get_turf(holder.my_atom), null))
		if(M.eyecheck() < FLASH_PROTECTION_MODERATE)
			M.flash_eyes()

	for(var/i = 1, i <= 4 + rand(1,2), i++)
		var/chosen = pick(borks)
		var/obj/B = new chosen
		if(B)
			B.forceMove(get_turf(holder.my_atom))
			if(prob(50))
				for(var/j = 1, j <= rand(1, 3), j++)
					step(B, pick(NORTH, SOUTH, EAST, WEST))
	..()

//Blue
/datum/chemical_reaction/metroid/frost
	name = "Metroid Frost Oil"
	result = /datum/reagent/frostoil
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	result_amount = 10
	required = /obj/item/metroid_extract/blue

/datum/chemical_reaction/metroid/foam
	name = "Metroid Foam"
	result = /datum/reagent/surfactant
	required_reagents = list(/datum/reagent/water = 1)
	result_amount = 10
	required = /obj/item/metroid_extract/blue

/datum/chemical_reaction/metroid/stabilizer
	name = "Metroid Stabilizer"
	result = null
	required_reagents = list(/datum/reagent/blood = 1)
	required = /obj/item/metroid_extract/blue

/datum/chemical_reaction/metroid/stabilizer/on_reaction(datum/reagents/holder)
	new /obj/item/metroid_stabilizer(get_turf(holder.my_atom))
	..()

//Dark Blue
/datum/chemical_reaction/metroid/freeze
	name = "Metroid Freeze"
	result = null
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	result_amount = 1
	required = /obj/item/metroid_extract/darkblue
	mix_message = "The metroid extract begins to vibrate violently!"

/datum/chemical_reaction/metroid/freeze/on_reaction(datum/reagents/holder)
	set waitfor = 0
	..()
	sleep(50)
	playsound(holder.my_atom, 'sound/effects/phasein.ogg', 100, 1)
	for(var/mob/living/M in range (get_turf(holder.my_atom), 7))
		M.bodytemperature -= 140
		to_chat(M, "<span class='warning'>You feel a chill!</span>")

/datum/chemical_reaction/metroid/chill_potion
	name = "Metroid Ñhill Potion"
	result = null
	required_reagents = list(/datum/reagent/water = 1)
	required = /obj/item/metroid_extract/darkblue

/datum/chemical_reaction/metroid/chill_potion/on_reaction(datum/reagents/holder)
	new /obj/item/chill_potion(get_turf(holder.my_atom))
	..()

//Orange
/datum/chemical_reaction/metroid/casp
	name = "Metroid Capsaicin Oil"
	result = /datum/reagent/capsaicin
	required_reagents = list(/datum/reagent/blood = 1)
	result_amount = 10
	required = /obj/item/metroid_extract/orange

/datum/chemical_reaction/metroid/fire
	name = "Metroid fire"
	result = null
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	result_amount = 1
	required = /obj/item/metroid_extract/orange
	mix_message = "The metroid extract begins to vibrate violently!"

/datum/chemical_reaction/metroid/fire/on_reaction(datum/reagents/holder)
	set waitfor = 0
	..()
	sleep(50)
	if(!(holder.my_atom && holder.my_atom.loc))
		return

	var/turf/location = get_turf(holder.my_atom)
	location.assume_gas("plasma", 250, 1400)
	location.hotspot_expose(700, 400)

//Yellow
/datum/chemical_reaction/metroid/overload
	name = "Metroid EMP"
	result = null
	required_reagents = list(/datum/reagent/blood = 1)
	result_amount = 1
	required = /obj/item/metroid_extract/yellow

/datum/chemical_reaction/metroid/overload/on_reaction(datum/reagents/holder, created_volume)
	..()
	empulse(get_turf(holder.my_atom), 3, 7)

/datum/chemical_reaction/metroid/cell
	name = "Metroid Powercell"
	result = null
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	result_amount = 1
	required = /obj/item/metroid_extract/yellow

/datum/chemical_reaction/metroid/cell/on_reaction(datum/reagents/holder, created_volume)
	..()
	new /obj/item/cell/metroid(get_turf(holder.my_atom))

/datum/chemical_reaction/metroid/glow
	name = "Metroid Glow"
	result = null
	required_reagents = list(/datum/reagent/water = 1)
	result_amount = 1
	required = /obj/item/metroid_extract/yellow
	mix_message = "The contents of the metroid core harden and begin to emit a warm, bright light."

/datum/chemical_reaction/metroid/glow/on_reaction(datum/reagents/holder, created_volume)
	..()
	new /obj/item/device/flashlight/metroid(get_turf(holder.my_atom))

//Purple
/datum/chemical_reaction/metroid/psteroid
	name = "Metroid Steroid"
	result = null
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	result_amount = 1
	required = /obj/item/metroid_extract/purple

/datum/chemical_reaction/metroid/psteroid/on_reaction(datum/reagents/holder, created_volume)
	..()
	var/obj/item/metroidsteroid/P = new /obj/item/metroidsteroid
	P.forceMove(get_turf(holder.my_atom))

/datum/chemical_reaction/metroid/jam
	name = "Metroid Jam"
	result = /datum/reagent/metroidjelly
	required_reagents = list(/datum/reagent/blood = 5)
	result_amount = 10
	required = /obj/item/metroid_extract/purple

//Dark Purple
/datum/chemical_reaction/metroid/plasma
	name = "Metroid Plasma"
	result = null
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	result_amount = 1
	required = /obj/item/metroid_extract/darkpurple

/datum/chemical_reaction/metroid/plasma/on_reaction(datum/reagents/holder)
	..()
	var/obj/item/stack/material/plasma/P = new /obj/item/stack/material/plasma
	P.amount = 3
	P.forceMove(get_turf(holder.my_atom))

//Red
/datum/chemical_reaction/metroid/mutation
	name = "Metroid Mutation"
	result = null
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	required = /obj/item/metroid_extract/red

/datum/chemical_reaction/metroid/mutation/on_reaction(datum/reagents/holder)
	new /obj/item/metroid_mutation(get_turf(holder.my_atom))
	..()

/datum/chemical_reaction/metroid/bloodlust
	name = "Bloodlust"
	result = null
	required_reagents = list(/datum/reagent/blood = 1)
	result_amount = 1
	required = /obj/item/metroid_extract/red

/datum/chemical_reaction/metroid/bloodlust/on_reaction(datum/reagents/holder)
	..()
	for(var/mob/living/carbon/metroid/metroid in viewers(get_turf(holder.my_atom), null))
		metroid.rabid = 1
		metroid.visible_message("<span class='warning'>The [metroid] is driven into a frenzy!</span>")

//Pink
/datum/chemical_reaction/metroid/docility
	name = "Metroid Docility"
	result = null
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	result_amount = 1
	required = /obj/item/metroid_extract/pink

/datum/chemical_reaction/metroid/docility/on_reaction(datum/reagents/holder)
	..()
	new /obj/item/metroidpotion(get_turf(holder.my_atom))

//Black
/datum/chemical_reaction/metroid/mutate2
	name = "Advanced Mutation Toxin"
	result = /datum/reagent/ametroidtoxin
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	result_amount = 1
	required = /obj/item/metroid_extract/black

//Oil
/datum/chemical_reaction/metroid/explosion
	name = "Metroid Explosion"
	result = null
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	result_amount = 1
	required = /obj/item/metroid_extract/oil
	mix_message = "The metroid extract begins to vibrate violently!"

/datum/chemical_reaction/metroid/explosion/on_reaction(datum/reagents/holder)
	set waitfor = 0
	..()
	sleep(50)
	explosion(get_turf(holder.my_atom), 1, 3, 6)

//Light Pink
/datum/chemical_reaction/metroid/potion2
	name = "Metroid Potion 2"
	result = null
	result_amount = 1
	required = /obj/item/metroid_extract/lightpink
	required_reagents = list(/datum/reagent/toxin/plasma = 1)

/datum/chemical_reaction/metroid/potion2/on_reaction(datum/reagents/holder)
	..()
	new /obj/item/metroidpotion2(get_turf(holder.my_atom))

//Adamantine
/datum/chemical_reaction/metroid/golem
	name = "Metroid Golem"
	result = null
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	result_amount = 1
	required = /obj/item/metroid_extract/adamantine

/datum/chemical_reaction/metroid/golem/on_reaction(datum/reagents/holder)
	..()
	new /obj/item/golem_shell(get_turf(holder.my_atom))

/datum/chemical_reaction/metroid/adamantine
	name = "Adamantine"
	result = null
	required_reagents = list(/datum/reagent/blood = 5)
	result_amount = 1
	required = /obj/item/metroid_extract/adamantine

/datum/chemical_reaction/metroid/adamantine/on_reaction(datum/reagents/holder)
	..()
	new /obj/item/stack/material/adamantine(get_turf(holder.my_atom))

//Sepia
/datum/chemical_reaction/metroid/film
	name = "Metroid Film"
	result = null
	required_reagents = list(/datum/reagent/blood = 1)
	result_amount = 2
	required = /obj/item/metroid_extract/sepia

/datum/chemical_reaction/metroid/film/on_reaction(datum/reagents/holder)
	for(var/i in 1 to result_amount)
		new /obj/item/device/camera_film(get_turf(holder.my_atom))
	..()

/datum/chemical_reaction/metroid/camera
	name = "Metroid Camera"
	result = null
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	result_amount = 1
	required = /obj/item/metroid_extract/sepia

/datum/chemical_reaction/metroid/camera/on_reaction(datum/reagents/holder)
	new /obj/item/device/camera(get_turf(holder.my_atom))
	..()

//Bluespace
/datum/chemical_reaction/metroid/teleport
	name = "Metroid Teleport"
	result = null
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	required = /obj/item/metroid_extract/bluespace
	reaction_sound = 'sound/effects/teleport.ogg'

/datum/chemical_reaction/metroid/teleport/on_reaction(datum/reagents/holder)
	new /obj/item/stack/telecrystal/bluespace_crystal(get_turf(holder.my_atom))
	..()

//pyrite
/datum/chemical_reaction/metroid/paint
	name = "Metroid Paint"
	result = null
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	required = /obj/item/metroid_extract/pyrite

/datum/chemical_reaction/metroid/paint/on_reaction(datum/reagents/holder)
	new /obj/item/reagent_containers/vessel/paint/random(get_turf(holder.my_atom))
	..()

/datum/chemical_reaction/metroid/crayon
	name = "Metroid Crayon"
	result = null
	required_reagents = list(/datum/reagent/blood = 1)
	required = /obj/item/metroid_extract/pyrite

/datum/chemical_reaction/metroid/crayon/on_reaction(datum/reagents/holder)
	new /obj/item/pen/crayon/random(get_turf(holder.my_atom))
	..()

//cerulean
/datum/chemical_reaction/metroid/extract_enhance
	name = "Extract Enhancer"
	result = null
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	required = /obj/item/metroid_extract/cerulean

/datum/chemical_reaction/metroid/extract_enhance/on_reaction(datum/reagents/holder)
	new /obj/item/metroidsteroid2(get_turf(holder.my_atom))
	..()

/datum/chemical_reaction/soap_key
	name = "Soap Key"
	result = null
	required_reagents = list(/datum/reagent/frostoil = 2, /datum/reagent/space_cleaner = 5)
	var/strength = 3

/datum/chemical_reaction/soap_key/can_happen(datum/reagents/holder)
	if(holder.my_atom && istype(holder.my_atom, /obj/item/soap))
		return ..()
	return 0

/datum/chemical_reaction/soap_key/on_reaction(datum/reagents/holder)
	var/obj/item/soap/S = holder.my_atom
	if(S.key_data)
		var/obj/item/key/soap/key = new(get_turf(holder.my_atom), S.key_data)
		key.uses = strength
	..()

//rainbow
/datum/chemical_reaction/metroid/random_metroid
	name = "Random Metroid"
	result = null
	required_reagents = list(/datum/reagent/toxin/plasma = 5)
	required = /obj/item/metroid_extract/rainbow

/datum/chemical_reaction/metroid/random_metroid/on_reaction(datum/reagents/holder)
	var/colour = pick(list(
		"green",
		"purple",
		"metal",
		"orange",
		"blue",
		"dark blue",
		"dark purple",
		"yellow",
		"silver",
		"pink",
		"red",
		"gold",
		"grey",
		"sepia",
		"bluespace",
		"cerulean",
		"pyrite",
		"light pink",
		"oil",
		"adamantine",
		"black"))
	new /mob/living/carbon/metroid(get_turf(holder.my_atom), colour)
	..()

/datum/chemical_reaction/metroid/mind_tansfer
	name = "Mind Transfer"
	result = null
	required_reagents = list(/datum/reagent/blood = 5)
	required = /obj/item/metroid_extract/rainbow

/datum/chemical_reaction/metroid/mind_tansfer/on_reaction(datum/reagents/holder)
	new /obj/item/metroid_transference/(get_turf(holder.my_atom))
	..()

/datum/chemical_reaction/metroid/metroidbomb
	name = "Metroid Bomb"
	result = null
	required_reagents = list(/datum/reagent/metroidjelly = 5)
	required = /obj/item/metroid_extract/rainbow

/datum/chemical_reaction/metroid/metroidbomb/on_reaction(datum/reagents/holder)
	var/turf/T = get_turf(holder.my_atom)
	var/obj/item/grenade/clusterbang/metroid/S = new (T)
	S.visible_message(SPAN_DANGER("Infused with slime jelly, the core begins to expand uncontrollably!"))
	S.icon_state = "metroidbang_active"
	S.active = TRUE
	S.set_next_think_ctx("think_detonate", world.time + rand(1.5 SECONDS, 6 SECONDS))
	var/lastkey = holder.my_atom.fingerprintslast
	message_admins("[key_name_admin(lastkey)] primed an explosive Brorble Brorble for detonation.")
	log_game("[key_name(lastkey)] primed an explosive Brorble Brorble for detonation.")
	..()
