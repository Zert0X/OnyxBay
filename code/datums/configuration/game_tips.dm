/datum/configuration_section/game_tips
    name = "game-tips"

    var/enable
    var/one_tip_for_everyone
    var/list/tips

    var/chosen_tip

/datum/configuration_section/game_tips/load_data(list/data)
    CONFIG_LOAD_BOOL(enable, data["enable"])
    CONFIG_LOAD_BOOL(one_tip_for_everyone, data["one_tip_for_everyone"])
    CONFIG_LOAD_LIST(tips, data["tips"])

    if(one_tip_for_everyone)
        chosen_tip = pick(tips)

/datum/configuration_section/game_tips/proc/get_tip()
    if(one_tip_for_everyone)
        return chosen_tip
    else
        return pick(tips)