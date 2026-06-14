
/obj/item/reagent_containers/vessel/plastic
	name = "plastic container"
	desc = "A container nonetheless."
	center_of_mass = "x=16;y=8"
	force = 4.5
	mod_weight = 0.45
	mod_reach = 0.25
	mod_handy = 0.65
	matter = list(MATERIAL_PLASTIC = 2000)

	volume = 0.5 LITER
	amount_per_transfer_from_this = 25
	possible_transfer_amounts = "25;30;50;100;150;250;300;500"

	lid_type = /datum/vessel_lid/cap
	brittle = FALSE
	unacidable = FALSE
	can_flip = TRUE
