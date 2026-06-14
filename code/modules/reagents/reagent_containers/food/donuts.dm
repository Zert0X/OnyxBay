
/obj/item/reagent_containers/food/donut
	name = "donut"
	desc = "Goes great with Robust Coffee."
	icon_state = "donut1"
	filling_color = "#d9c386"
	center_of_mass = "x=13;y=16"
	nutriment_amt = 40
	nutriment_desc = list("donut" = 2)
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 10,
		/datum/reagent/sugar = 10
		)
	bitesize = 20 // 115 nutrition, 3 bites

	var/overlay_state = "box-donut1"

/obj/item/reagent_containers/food/donut/normal
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 10
		)
	bitesize = 20 // 115 nutrition, 3 bites

/obj/item/reagent_containers/food/donut/normal/Initialize()
	. = ..()
	if(prob(30))
		SetName("frosted donut")
		icon_state = "donut2"
		overlay_state = "box-donut2"
		center_of_mass = "x=19;y=16"
		reagents.add_reagent(/datum/reagent/nutriment/sprinkles, 10)
	else
		reagents.add_reagent(/datum/reagent/sugar, 10)

/obj/item/reagent_containers/food/donut/chaos
	name = "Chaos Donut"
	desc = "Like life, it never quite tastes the same."
	icon_state = "donut1"
	filling_color = "#ed11e6"
	nutriment_amt = 40
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 10
		)
	bitesize = 25 // 115 to 165 nutrition, 3 bites

/obj/item/reagent_containers/food/donut/chaos/Initialize()
	. = ..()
	var/chaosselect = rand(1, 10)
	switch(chaosselect)
		if(1)
			reagents.add_reagent(/datum/reagent/nutriment, 10)
		if(2)
			reagents.add_reagent(/datum/reagent/capsaicin, 10)
		if(3)
			reagents.add_reagent(/datum/reagent/frostoil, 10)
		if(4)
			reagents.add_reagent(/datum/reagent/nutriment/sprinkles, 10)
		if(5)
			reagents.add_reagent(/datum/reagent/toxin/plasma, 10)
		if(6)
			reagents.add_reagent(/datum/reagent/nutriment/coco, 10)
		if(7)
			reagents.add_reagent(/datum/reagent/metroidjelly, 10)
		if(8)
			reagents.add_reagent(/datum/reagent/drink/juice/banana, 10)
		if(9)
			reagents.add_reagent(/datum/reagent/drink/juice/berry, 10)
		if(10)
			reagents.add_reagent(/datum/reagent/tricordrazine, 10)

	if(prob(30))
		src.icon_state = "donut2"
		src.overlay_state = "box-donut2"
		src.SetName("Frosted Chaos Donut")
		reagents.add_reagent(/datum/reagent/nutriment/sprinkles, 10)
	else
		reagents.add_reagent(/datum/reagent/sugar, 10)

/obj/item/reagent_containers/food/donut/jelly
	name = "Jelly Donut"
	desc = "You jelly?"
	icon_state = "jdonut1"
	filling_color = "#ed1169"
	center_of_mass = "x=16;y=11"
	nutriment_amt = 40
	nutriment_desc = list("berry jelly" = 2, "donut" = 2)
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 10,
		/datum/reagent/drink/juice/berry = 30
		)
	bitesize = 30 // 160 nutrition, 3 bites

/obj/item/reagent_containers/food/donut/jelly/Initialize()
	. = ..()
	if(prob(30))
		src.icon_state = "jdonut2"
		src.overlay_state = "box-donut2"
		src.SetName("Frosted Jelly Donut")
		reagents.add_reagent(/datum/reagent/nutriment/sprinkles, 10)
	else
		reagents.add_reagent(/datum/reagent/sugar, 10)

/obj/item/reagent_containers/food/donut/metroidjelly
	name = "Jelly Donut"
	desc = "You jelly?"
	icon_state = "jdonut1"
	filling_color = "#ed1169"
	center_of_mass = "x=16;y=11"
	nutriment_amt = 40
	nutriment_desc = list("weird jelly" = 2, "donut" = 2)
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 10,
		/datum/reagent/metroidjelly = 10
		)
	bitesize = 25 // 115 nutrition, 3 bites

/obj/item/reagent_containers/food/donut/metroidjelly/Initialize()
	. = ..()
	if(prob(30))
		src.icon_state = "jdonut2"
		src.overlay_state = "box-donut2"
		src.SetName("Frosted Jelly Donut")
		reagents.add_reagent(/datum/reagent/nutriment/sprinkles, 10)
	else
		reagents.add_reagent(/datum/reagent/sugar, 10)

/obj/item/reagent_containers/food/donut/cherryjelly
	name = "Jelly Donut"
	desc = "You jelly?"
	icon_state = "jdonut1"
	filling_color = "#ed1169"
	center_of_mass = "x=16;y=11"
	nutriment_amt = 40
	nutriment_desc = list("berry jelly" = 2, "donut" = 2)
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 10,
		/datum/reagent/nutriment/cherryjelly = 30
		)
	bitesize = 30 // 160 nutrition, 3 bites

/obj/item/reagent_containers/food/donut/cherryjelly/Initialize()
	. = ..()
	if(prob(30))
		src.icon_state = "jdonut2"
		src.overlay_state = "box-donut2"
		src.SetName("Frosted Jelly Donut")
		reagents.add_reagent(/datum/reagent/nutriment/sprinkles, 10)
	else
		reagents.add_reagent(/datum/reagent/sugar, 10)
