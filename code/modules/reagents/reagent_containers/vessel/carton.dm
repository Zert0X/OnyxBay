
/obj/item/reagent_containers/vessel/carton
	name = "carton"
	desc = "A carton."
	center_of_mass = "x=16;y=8"
	force = 2.5
	mod_weight = 0.45
	mod_reach = 0.25
	mod_handy = 0.65
	matter = list(MATERIAL_CARDBOARD = 2000)
	w_class = ITEM_SIZE_NORMAL

	volume = 1.0 LITER
	amount_per_transfer_from_this = 25
	possible_transfer_amounts = "25;30;50;60;100;150;250;300;1000"

	lid_type = /datum/vessel_lid/carton
	brittle = FALSE
	unacidable = FALSE
	can_flip = TRUE

/obj/item/reagent_containers/vessel/carton/get_storage_cost()
	return ..() * 1.5
