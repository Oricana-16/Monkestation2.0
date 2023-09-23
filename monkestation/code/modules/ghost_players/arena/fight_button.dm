/obj/structure/fight_button
	name = "duel requestor 3000"
	desc = "A button that displays your intent to duel aswell as the weapon of choice and stakes of the duel."

	icon_state = "comp_button1"
	icon = 'goon/icons/obj/mechcomp.dmi'

	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE

	///player vars
	var/mob/living/carbon/human/ghost/player_one
	var/mob/living/carbon/human/ghost/player_two
	///the selected item both players spawn with
	var/obj/item/weapon_of_choice = /obj/item/storage/toolbox
	///the wager in monkecoins thats paid out to the winner
	var/payout = 0

	var/list/weapon_choices = list(
		/obj/item/storage/toolbox,
		/obj/item/knife/shiv,
	)
	///our generated maptext
	var/image/visual_maptext/generated_maptext

	///player storages
	var/list/player_one_storage = list()
	var/list/player_two_storage = list()

/obj/structure/fight_button/Initialize(mapload)
	. = ..()
	update_maptext()
	register_context()

/obj/structure/fight_button/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	context[SCREENTIP_CONTEXT_LMB] = "Join Duel"
	context[SCREENTIP_CONTEXT_RMB] = "Leave Duel"
	return CONTEXTUAL_SCREENTIP_SET

/obj/structure/fight_button/proc/update_maptext()
	var/string = "Player One:[player_one ? "[player_one.real_name]" : "No One"] \n Player Two:[player_two ? "[player_two.real_name]" : "No One"] \n Weapon of Choice: [initial(weapon_of_choice.name)]\n Wager: [payout]"

	if(generated_maptext)
		qdel(generated_maptext)
	generated_maptext = generate_maptext(src, string, x_offset = -8, y_offset = 32)
	update_appearance()

/obj/structure/fight_button/update_overlays()
	. = ..()
	cut_overlays()
	if(generated_maptext)
		add_overlay(generated_maptext)


/obj/structure/fight_button/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(!istype(user, /mob/living/carbon/human/ghost))
		return

	if(!player_one)
		if(!set_rules(user))
			return
		player_one = user
		player_one.linked_button = src
		update_maptext()
	else if(!player_two && user != player_one)
		if(user.client.prefs.metacoins < payout)
			to_chat(user, span_warning("You do not have the funds to compete in this wager!"))
			return
		player_two = user
		player_two.linked_button = src
		if(player_one && player_two)
			update_maptext()
			addtimer(CALLBACK(src, PROC_REF(prep_round)), 5 SECONDS)


/obj/structure/fight_button/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(user == player_one)
		break_off_game()
		player_one = null

	else if(user == player_two)
		player_two.linked_button = null
		player_two = null

/obj/structure/fight_button/proc/remove_user(mob/living/carbon/human/ghost/vanisher)
	if(player_one == vanisher)
		break_off_game()
		player_one = null
		update_maptext()
	if(player_two == vanisher)
		player_two = null
		update_maptext()

/obj/structure/fight_button/proc/break_off_game()
	say("[player_one.real_name] has recinded their dueling request, and as such the match has been cancelled.")
	if(player_two)
		to_chat(player_two, span_warning("You get a notification, it seems the duel has been cancelled."))
		player_two.linked_button = null
		player_two = null
	payout = 0
	player_one.linked_button = null

/obj/structure/fight_button/proc/set_rules(mob/living/carbon/human/ghost/user)
	var/max_amount = user.client.prefs.metacoins
	var/choice = tgui_input_number(user, "How much would you like to wager?", "[src.name]", 100, max_amount, 100)
	if(!choice)
		return FALSE
	payout = choice

	var/weapon_choice = tgui_input_list(user, "Choose the dueling weapon", "[src.name]", weapon_choices)
	if(!weapon_choice)
		return FALSE
	weapon_of_choice = weapon_choice
	return TRUE

/obj/structure/fight_button/proc/prep_round()
	if(!player_one || !player_two)
		payout = 0
		say("One or more of the players have left the area, match has been cancelled!")
		return


	if(!player_one.client.prefs.adjust_metacoins(player_one.ckey, -payout, "Added to the Payout"))
		return
	if(!player_two.client.prefs.adjust_metacoins(player_one.ckey, -payout, "Added to the Payout"))
		player_one.client.prefs.adjust_metacoins(player_one.ckey, payout, "Opponent left, reimbursed.")
		return


	player_one_storage = player_one.unequip_everything_return_list()
	for(var/atom/movable/atom in player_one_storage)
		atom.forceMove(src)

	player_two_storage = player_two.unequip_everything_return_list()
	for(var/atom/movable/atom in player_two_storage)
		atom.forceMove(src)

	var/obj/item/one_weapon = new weapon_of_choice(src)
	var/turf/one_spot = locate(161, 49, SSmapping.levels_by_trait(ZTRAIT_CENTCOM)[1])
	player_one.forceMove(one_spot)
	player_one.equipOutfit(/datum/outfit/job/assistant)
	player_one.put_in_active_hand(one_weapon, TRUE)
	player_one.dueling = TRUE

	var/obj/item/two_weapon = new weapon_of_choice(src)
	var/turf/two_spot = locate(177, 49, SSmapping.levels_by_trait(ZTRAIT_CENTCOM)[1])
	player_two.forceMove(two_spot)
	player_two.equipOutfit(/datum/outfit/job/assistant)
	player_two.put_in_active_hand(two_weapon, TRUE)
	player_two.dueling = TRUE

/obj/structure/fight_button/proc/end_duel(mob/living/carbon/human/ghost/loser)
	if(loser == player_one)
		player_two.client.prefs.adjust_metacoins(player_one.ckey, payout * 2, "Won Duel.", donator_multipler = FALSE)
	else if(loser == player_two)
		player_one.client.prefs.adjust_metacoins(player_one.ckey, payout * 2, "Won Duel.", donator_multipler = FALSE)
	addtimer(CALLBACK(src, GLOBAL_PROC_REF(reset_arena_area)), 5 SECONDS)

	player_one.linked_button = null
	player_two.linked_button = null
	player_one.dueling = FALSE
	player_two.dueling = FALSE

	var/turf/player_one_turf = get_turf(player_one)
	for(var/atom/movable/atom in player_one_storage)
		atom.forceMove(player_one_turf)

	var/turf/player_two_turf = get_turf(player_two)
	for(var/atom/movable/atom in player_two_storage)
		atom.forceMove(player_two_turf)

	player_one_storage = list()
	player_two_storage = list()

	player_one = null
	player_two = null

	payout = 0
	update_maptext()

/mob/living/proc/unequip_everything_return_list()
	var/list/items = list()
	items |= get_equipped_items(TRUE)
	for(var/I in items)
		dropItemToGround(I)
	items += drop_all_held_items_return_list()
	return items

/mob/proc/drop_all_held_items_return_list()
	. = FALSE
	var/list/items = list()
	for(var/obj/item/I in held_items)
		items += I
		. |= dropItemToGround(I)
	return items
