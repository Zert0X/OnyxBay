/obj/item/device/t_scanner/emitter_controller 
    var/control_mode = FALSE
    var/list/modes = list("activate", "deactivate", "toggle lock")
    var/cur_mode = "activate"
    var/_wifi_id
    var/datum/wifi/sender/emitter/wifi_sender = new
    var/list/allowed_to_control = list(/obj/machinery/power/emitter, /obj/machinery/power/emitter/gyrotron)

/obj/item/device/t_scanner/emitter_controller/Initialize()
    . = ..()
    _wifi_id = "[rand(1, 100)]"
    wifi_sender = new (_wifi_id)
    verbs -= /obj/item/device/t_scanner/emitter_controller/verb/toggle_mode
    verbs -= /obj/item/device/t_scanner/emitter_controller/verb/clear_memory

/obj/item/device/t_scanner/emitter_controller/attack_self(mob/user)
    if(control_mode)
        if(!wifi_sender)
            return
        wifi_sender.activate(cur_mode, user)
        playsound(src.loc, 'sound/effects/compbeep3.ogg', 50)
    else
        ..()

/obj/item/device/t_scanner/emitter_controller/verb/toggle_mode()
    set name = "Toggle Mode"
    set category = "Object"
    set desc = "Toggles mode of connected devices."

    if(usr.incapacitated())
        return

    var/new_index = modes.Find(cur_mode)
    if(!new_index)
        new_index = 0
    else
        new_index = new_index == modes.len ? 1 : new_index+1
    cur_mode = modes[new_index]
    playsound(src.loc, 'sound/effects/compbeep1.ogg', 50)

/obj/item/device/t_scanner/emitter_controller/verb/clear_memory()
    set name = "Clear Memory"
    set category = "Object"
    set desc = "Clears the memory of the controller."

    if(usr.incapacitated())
        return

    for(var/datum/wifi/receiver/button/emitter/B in wifi_sender.connected_devices)
        if(!isnull(B.parent))
            var/obj/machinery/power/emitter/E = B.parent
            qdel(E.wifi_receiver)
            E.wifi_receiver = null
            wifi_sender.disconnect_device(E.wifi_receiver)
        qdel(B)
        B = null

    wifi_sender.connected_devices = list()
    playsound(src.loc, 'sound/machines/triple_beep.ogg', 50)


/obj/item/device/t_scanner/emitter_controller/attackby(obj/item/W, mob/user) 
    if(isScrewdriver(W))
        control_mode = !control_mode
        if(control_mode)
            verbs += /obj/item/device/t_scanner/emitter_controller/verb/toggle_mode
            verbs += /obj/item/device/t_scanner/emitter_controller/verb/clear_memory
        else
            verbs -= /obj/item/device/t_scanner/emitter_controller/verb/toggle_mode
            verbs -= /obj/item/device/t_scanner/emitter_controller/verb/clear_memory
        playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
    else
        ..()

/obj/item/device/t_scanner/emitter_controller/resolve_attackby(atom/A, mob/user)
    if(!control_mode)
        ..()
        return
    if(!is_type_in_list(A, allowed_to_control))
        return
    if(wifi_sender.connected_devices.len > 2) 
        playsound(src.loc, 'sound/machines/buzz-sigh.ogg', 50)
        return
    var/obj/machinery/power/emitter/E = A
    if(isnull(E.wifi_receiver))
        E.wifi_receiver = new(_wifi_id, E)
    else
        E.wifi_receiver.id = _wifi_id

    wifi_sender.connect_device(E.wifi_receiver)
    playsound(src.loc, 'sound/effects/compbeep1.ogg', 50)  
