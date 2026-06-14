/obj/item/rcd_ammo/magnetic_ammo
	name = "flechette magazine"
	desc = "A magazine containing steel flechettes."
	icon = 'icons/obj/ammo.dmi'
	icon_state = "5.56"
	item_state = "syringe_kit"
	w_class = ITEM_SIZE_SMALL
	matter = list(MATERIAL_STEEL = 1800)
	origin_tech = list(TECH_COMBAT = 1)
	ammoamt = 9

/obj/item/rcd_ammo/magnetic_ammo/get_ammo_desc()
	return "There [(ammoamt == 1)? "is" : "are"] [ammoamt] flechette\s left!"
