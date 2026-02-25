/obj/machinery/computer/curer
	name = "treatment builder"
	icon = 'icons/obj/computer.dmi'
	icon_keyboard = "med_key"
	icon_screen = "dna"
	circuit = /obj/item/circuitboard/curefab
	idle_power_usage = 500 WATTS
	var/curing
	var/virusing
	var/production_mode

	var/obj/item/reagent_containers/container = null

/obj/machinery/computer/curer/attackby(obj/I as obj, mob/user as mob)
	if(istype(I,/obj/item/reagent_containers))
		var/mob/living/carbon/C = user
		if(!container && C.drop(I, src))
			container = I
		return
	if(istype(I,/obj/item/virusdish))
		if(virusing)
			to_chat(user, "<b>The pathogen materializer is still recharging..</b>")
			return
		var/obj/item/reagent_containers/vessel/beaker/product = new(src.loc)

		var/list/data = list("donor" = null, "blood_DNA" = null, "blood_type" = null, "trace_chem" = null, "virus2" = list(), "antibodies" = list(), "antibody_epitopes" = list())
		data["virus2"] |= I:virus2
		product.reagents.add_reagent(/datum/reagent/blood, 30, data)

		virusing = 1
		spawn(1200) virusing = 0

		state("The [src.name] Buzzes", "blue")
		return
	..()
	return

/obj/machinery/computer/curer/attack_ai(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/curer/attack_hand(mob/user as mob)
	if(..())
		return
	user.set_machine(src)
	var/dat = "<meta charset=\"utf-8\">"
	if(curing)
		dat += "Treatment synthesis in progress"
	else if(virusing)
		dat += "Pathogen materialization in progress"
	else if(container)
		var/datum/reagent/blood/B = locate(/datum/reagent/blood) in container.reagents.reagent_list
		if(B)
			dat += "Blood sample inserted."
			dat += "<BR>Known antibodies: [antigens2string(B.data[\"antibodies\"])]"
			var/datum/disease2/disease/reference = get_reference_pathogen(B)
			if(reference)
				dat += "<BR>Target signature: [antigens2string(reference.antigen)]"
				dat += "<BR>Knowledge level: [reference.knowledge ? reference.knowledge.get_level_label() : \"Unknown\"]"
			dat += "<BR><A href='?src=\ref[src];build=suppressor'>Assemble temporary suppressor</a>"
			dat += "<BR><A href='?src=\ref[src];build=target'>Assemble target-agent</a>"
			dat += "<BR><A href='?src=\ref[src];build=vaccine'>Assemble adaptive vaccine</a>"
		else
			dat += "<BR>Please check container contents."
		dat += "<BR><A href='?src=\ref[src];eject=1'>Eject container</a>"
	else
		dat = "Please insert a container."

	show_browser(user, dat, "window=computer;size=420x520")
	onclose(user, "computer")
	return

/obj/machinery/computer/curer/Process()
	..()

	if(stat & (NOPOWER|BROKEN))
		return

	if(curing)
		curing -= 1
		if(curing == 0)
			if(container)
				create_treatment(container, production_mode)
			production_mode = null
	return

/obj/machinery/computer/curer/OnTopic(user, href_list)
	if(href_list["build"])
		production_mode = href_list["build"]
		curing = 10
		. = TOPIC_REFRESH
	else if(href_list["eject"])
		container.dropInto(loc)
		container = null
		. = TOPIC_REFRESH

	if(. == TOPIC_REFRESH)
		attack_hand(user)

/obj/machinery/computer/curer/proc/get_reference_pathogen(datum/reagent/blood/B)
	if(!B || !B.data || !B.data["virus2"])
		return null
	for(var/id in B.data["virus2"])
		var/datum/disease2/disease/V = B.data["virus2"][id]
		if(V)
			return V
	return null

/obj/machinery/computer/curer/proc/create_treatment(obj/item/reagent_containers/container, mode)
	var/obj/item/reagent_containers/vessel/beaker/product = new(src.loc)
	var/datum/reagent/blood/B = locate() in container.reagents.reagent_list
	if(!B)
		state("\The [src.name] buzzes", "red")
		return

	var/datum/disease2/disease/reference = get_reference_pathogen(B)
	var/list/target_signature = reference ? normalize_antibody_map(reference.antigen) : normalize_antibody_map(B.data["antibodies"])
	var/list/data = list("antibodies" = list(), "antibody_epitopes" = list())

	switch(mode)
		if("suppressor")
			for(var/epitope in target_signature)
				antibody_map_add_variant(data["antibodies"], epitope, "*")
			product.reagents.add_reagent(/datum/reagent/spaceacillin, 10)
			product.reagents.add_reagent(/datum/reagent/antibodies, 20, data)
		if("target")
			data["antibodies"] = normalize_antibody_map(target_signature)
			product.reagents.add_reagent(/datum/reagent/antibodies, 30, data)
		if("vaccine")
			var/knowledge_level = reference && reference.knowledge ? reference.knowledge.knowledge_level : 0
			if(knowledge_level >= 3)
				data["antibodies"] = normalize_antibody_map(target_signature)
			else
				for(var/epitope in target_signature)
					antibody_map_add_variant(data["antibodies"], epitope, "*")
			product.reagents.add_reagent(/datum/reagent/antibodies, 30, data)
		else
			data["antibodies"] = normalize_antibody_map(B.data["antibodies"])
			product.reagents.add_reagent(/datum/reagent/antibodies, 30, data)

	data["antibody_epitopes"] = data["antibodies"] ? data["antibodies"].Copy() : list()
	var/datum/reagent/antibodies/A = locate(/datum/reagent/antibodies) in product.reagents.reagent_list
	if(A)
		A.data = data.Copy()
	state("\The [src.name] buzzes", "blue")
