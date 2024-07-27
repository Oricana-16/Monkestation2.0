#define SPELL_DISPLACEMENT_RANGE 7

// /obj/effect/proc_holder/spell/aoe_turf/knock/living_lube
// 	action_background_icon_state = "bg_hive" //closest to a pink spell color we have
// 	charge_max = 30 SECONDS
// 	range = 5
// 	invocation = "AULIE HONKSIN FIERA"
// 	invocation_type = "whisper"

// /obj/effect/proc_holder/spell/aimed/banana_peel/living_lube
// 	action_background_icon_state = "bg_hive"

// /obj/effect/proc_holder/spell/voice_of_god/clown/living_lube
// 	action_background_icon_state = "bg_hive"
// 	power_mod = 0.5 //Slightly more annoying

/datum/action/cooldown/spell/living_lube
	spell_requirements = SPELL_REQUIRES_MIND
	check_flags = AB_CHECK_CONSCIOUS
	invocation_type = INVOCATION_NONE
	background_icon_state = "bg_hive"
	overlay_icon_state = "bg_hive_border"

/datum/action/cooldown/spell/living_lube/displace
	name = "Displace"
	desc = "Force someone through the clown dimension and launch them out somewhere else on the station!"
	button_icon = 'icons/mob/actions/actions_spells.dmi'

/datum/action/cooldown/spell/living_lube/displace/cast(list/targets, mob/user = usr)
	var/target = targets[1]

	if(!isliving(target))
		return

	if(get_dist(user,target)>SPELL_DISPLACEMENT_RANGE)
		to_chat(user, span_notice("\The [target] is too far away!"))
		return

	do_teleport(target,find_safe_turf(),asoundin = 'sound/items/bikehorn.ogg')
	to_chat(target,span_warning("A loud honk echoes your bones as you appear somewhere else!"))
	. = ..()

#undef SPELL_DISPLACEMENT_RANGE
