/obj/machinery/disease2/diseaseanalyser
	name = "disease analyser"
	icon = 'icons/obj/virology.dmi'
	icon_state = "analyser"
	anchored = 1
	density = 1
	component_types = list(
		/obj/item/stock_parts/scanning_module = 2,
		/obj/item/stock_parts/console_screen,
		/obj/item/circuitboard/analyser
	)

	var/scanning = 0
	var/pause = 0

	var/speed = 1

	var/obj/item/virusdish/dish = null

/obj/machinery/disease2/diseaseanalyser/Initialize()
	. = ..()
	RefreshParts()

/obj/machinery/disease2/diseaseanalyser/attackby(obj/O, mob/user)
	if(scanning)
		to_chat(user, SPAN("notice", "\The [src] is busy. Please wait for completion of previous operation."))
		return 1
	if(dish)
		to_chat(user, SPAN("notice", "\The [src] is full. Please remove external items."))
		return 1
	if(default_deconstruction_screwdriver(user, O))
		return
	if(default_deconstruction_crowbar(user, O))
		return
	if(default_part_replacement(user, O))
		return

	if(!istype(O, /obj/item/virusdish))
		return

	if(dish)
		to_chat(user, SPAN("notice", "\The [src] is already loaded."))
		return

	if(!user.drop(O, src))
		return

	dish = O
	user.visible_message("[user] adds \a [O] to \the [src]!", "You add \a [O] to \the [src]!")


/obj/machinery/disease2/diseaseanalyser/attack_hand(mob/user)
	if(stat & (NOPOWER|BROKEN))
		return
	tgui_interact(user)

/obj/machinery/disease2/diseaseanalyser/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Disease2Console", name)
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/machinery/disease2/diseaseanalyser/tgui_data(mob/user)
	var/list/rapid_assay = null
	if(dish && dish.virus2)
		var/datum/disease2/disease/V = dish.virus2
		var/tropism = "Systemic"
		if(findtext(lowertext(V.transmission_mode_to_text()), "air"))
			tropism = "Respiratory"
		else if(findtext(lowertext(V.transmission_mode_to_text()), "blood"))
			tropism = "Hematologic"
		var/list/antigen_signature = V.get_antigen_signature()
		var/vulnerability = antigen_signature && length(antigen_signature) ? "Antigen docking" : "Broad epithelial inhibitors"
		var/suppressor = V.infectionchance >= 60 ? "Aggressive antiviral suppressor" : "Standard antiviral suppressor"
		rapid_assay = list(
			"eta" = "2-3 minutes",
			"tropism" = tropism,
			"vulnerabilityClass" = vulnerability,
			"suppressor" = suppressor
		)
	return list(
		"machineType" = "analyser",
		"screen" = "rapid_assay",
		"dishInserted" = !!dish,
		"scanning" = scanning,
		"growth" = dish ? dish.growth : 0,
		"rapidAssay" = rapid_assay
	)

/obj/machinery/disease2/diseaseanalyser/tgui_act(action, params)
	. = ..()
	if(.)
		return
	if(action == "eject" && dish && !scanning)
		dish.dropInto(loc)
		dish = null
	tgui_update()
	return TRUE

/obj/machinery/disease2/diseaseanalyser/Process()
	if(stat & (NOPOWER|BROKEN))
		return

	if(scanning)
		scanning = max(0, scanning - 1 * speed)
		if(!scanning)
			if (dish.virus2.addToDB())
				ping("\The [src] pings, \"New pathogen added to data bank.\"")

			var/obj/item/paper/P = new /obj/item/paper(src.loc)
			P.SetName("paper - [dish.virus2.name()]")

			var/r = dish.virus2.get_info()
			P.info = {"
				[virology_letterhead("Post-Analysis Memo")]
				[r]
				<hr>
				<u>Additional Notes:</u>&nbsp;
	"}
			dish.basic_info = dish.virus2.get_basic_info()
			dish.info = r
			dish.SetName("[initial(dish.name)] ([dish.virus2.name()])")
			dish.analysed = 1
			dish.dropInto(loc)
			dish = null

			icon_state = "analyser"
			src.state("\The [src] prints a sheet of paper.")

	else if(dish && !scanning && !pause)
		if(dish.virus2 && dish.growth > 50)
			dish.growth -= 10
			scanning = 5
			icon_state = "analyser_processing"
		else
			pause = 1
			spawn(25)
				dish.dropInto(loc)
				dish = null

				src.state(SPAN("warning", "\The [src] buzzes, \"Insufficient growth density to complete analysis.\""))
				pause = 0
	return

/obj/machinery/disease2/diseaseanalyser/RefreshParts()
	var/T = 0
	for(var/obj/item/stock_parts/scanning_module/S in component_parts)
		T += S.rating
	speed = T/2
