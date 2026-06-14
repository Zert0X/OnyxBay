/obj/item/reagent_containers/spray/luminol
	name = "luminol bottle"
	desc = "A bottle containing an odourless, colorless liquid."
	icon = 'icons/obj/forensics.dmi'
	icon_state = "luminol"
	item_state = "cleaner"
	amount_per_transfer_from_this = 10
	spray_size = 1
	possible_transfer_amounts = "10;25"
	volume = 0.5 LITERS

/obj/item/reagent_containers/spray/luminol/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/luminol, 0.5 LITERS)
