/obj/item/clothing/accessory/shoe_covers
	name = "shoe covers"
	desc = "High quality floor protection from your dirty feet"
	icon_state = "shoe_covers"
	body_parts_covered = NO_BODYPARTS
	slot_flags = SLOT_FEET|SLOT_HEAD
	slot = ACCESSORY_SLOT_COVER
	valid_accessory_slots = list(ACCESSORY_SLOT_COVER)
	var/old_track_blood = 0
	var/list/list_covers = list()
	var/chance_destroy = 5
	var/footstep = 1

/obj/item/clothing/accessory/shoe_covers/attack_hand(mob/user)
	if(has_suit)
		has_suit.remove_accessory(user, src)
		return

	..()

/obj/item/clothing/accessory/shoe_covers/on_removed(mob/user)
	if(has_suit)
		var/new_chance_destroy = chance_destroy
		if(!do_after(user, rand(3, 10)))
			new_chance_destroy = chance_destroy * 15

		var/obj/item/clothing/shoes/SS = has_suit
		if(old_track_blood > 0)
			SS.track_blood = old_track_blood

		has_suit.CutOverlays(get_inv_overlay())
		has_suit = null

		if(prob(new_chance_destroy))
			to_chat(user, SPAN_WARNING("\The [src] was torn off \the [SS]!"))
			torn()
		else
			if(user.pick_or_drop(src))
				add_fingerprint(user)
			else
				to_chat(user, SPAN_WARNING("Your need an empty, unbroken hand to do that."))
				forceMove(has_suit)

/obj/item/clothing/accessory/shoe_covers/proc/torn()
	var/BS = new /obj/effect/decal/cleanable/generic/blue_shards(get_turf(src))
	playsound(BS, 'sound/effects/destroy_covers.ogg', 80, 1)
	Destroy()

/obj/item/clothing/accessory/shoe_covers/on_attached(obj/item/clothing/S, mob/user)
	if(!istype(S))
		return FALSE

	if(istype(S, /obj/item/clothing/shoes/swimmingfins) || istype(S, /obj/item/clothing/shoes/clown_shoes))
		to_chat(user, SPAN_WARNING("\The [S] tore \the [src]!"))
		torn()
		return FALSE

	var/count_SC = 0
	for (var/obj/item/clothing/accessory/shoe_covers/SC in S.accessories)
		if (!isnull(SC) && SC != src)
			count_SC++

	if (count_SC > 0)
		to_chat(user, SPAN_NOTICE("You find putting an [src] in another to be slightly [prob(count_SC * 5) ? "genius" : "absurd"]."))
	else
		to_chat(user, SPAN_NOTICE("You attach \the [src] to \the [S]."))

	has_suit = S
	forceMove(has_suit)
	has_suit.AddOverlays(get_inv_overlay())

	if(user)
		add_fingerprint(user)

	if(istype(has_suit, /obj/item/clothing/shoes))
		var/obj/item/clothing/shoes/SS = has_suit
		old_track_blood = SS.track_blood
		SS.track_blood = 0
	return TRUE

/obj/item/clothing/accessory/shoe_covers/proc/handle_movement(turf/walking, running, is_barefoot)
	if(running)
		if(footstep >= 2)
			footstep = 0
			playsound(src, SFX_SHOE_COVERS, 70, 1)
		else
			footstep++
		if(!is_barefoot && prob(chance_destroy/10))
			torn()
	else
		playsound(src, SFX_SHOE_COVERS, 40, 1)

/obj/item/clothing/accessory/shoe_covers/get_inv_overlay()
	if(!inv_overlay)
		inv_overlay = image(icon, icon_state, dir = SOUTH)
	inv_overlay.color = color
	return inv_overlay

/obj/item/compact_shoe_covers
	name = "compact shoe covers"
	desc = "A neatly folded bundle of disposable shoe covers. Conveniently compact, but ready to unfold at a moment's notice"
	w_class = ITEM_SIZE_TINY
	icon_state = "compact_shoe_covers"
	var/obj/item/clothing/accessory/shoe_covers/covers = new()

/obj/item/compact_shoe_covers/attack_self(mob/user)
	if(user && covers)
		playsound(user, 'sound/effects/destroy_covers.ogg', 80, 1)
		if(user.pick_or_drop(covers))
			covers.add_fingerprint(user)
		else
			covers.forceMove(user.loc)
	Destroy()

/obj/item/storage/box/compact_shoe_covers
	name = "box of compact shoe covers"
	desc = "This box of compactly packed shoe covers."
	icon_state = "covers"
	startswith = list(/obj/item/compact_shoe_covers = 14)
