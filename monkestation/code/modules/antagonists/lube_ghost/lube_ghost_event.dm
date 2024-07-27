/datum/round_event_control/lube_ghost
	name = "Ghost of Stations Past"
	typepath = /datum/round_event/ghost_role/lube_ghost
	weight = 3
	max_occurrences = 1

/datum/round_event/ghost_role/lube_ghost
	minimum_required = 1
	role_name = "Living Lube Ghost"
	fakeable = FALSE

/datum/round_event/ghost_role/lube_ghost/spawn_role()
	var/list/mob/dead/observer/candidates = SSpolling.poll_ghost_candidates(
		"Do you want to play as a Living Lube Ghost?",
		role = ROLE_LUBE_GHOST,
		poll_time = 30 SECONDS,
		pic_source = /datum/antagonist/lube_ghost,
		role_name_text = "living lube ghost"
	)

	if(!candidates.len)
		return NOT_ENOUGH_PLAYERS

	var/mob/dead/selected = pick_n_take(candidates)

	// Spawn the Lube
	var/turf/chosen_spawn
	chosen_spawn = GLOB.generic_event_spawns.len ? pick(GLOB.generic_event_spawns) : null
	var/mob/living/basic/clown/lube/lube_ghost = new(chosen_spawn)
	// Can't Spawn
	if(!chosen_spawn)
		SSjob.SendToLateJoin(lube_ghost, FALSE)

	var/datum/mind/ghost_mind = new /datum/mind(selected.key)
	ghost_mind.assigned_role = "Clown" //Officially a clown
	ghost_mind.special_role = "Ghost of Stations Past"
	ghost_mind.active = TRUE
	ghost_mind.transfer_to(lube_ghost)
	ghost_mind.add_antag_datum(/datum/antagonist/lube_ghost)

	message_admins("[ADMIN_LOOKUPFLW(lube_ghost)] has been made into a Ghost of Stations Past.")
	log_game("[key_name(lube_ghost)] was spawned as Ghost of Stations Past by an event.")

	spawned_mobs += lube_ghost

	return SUCCESSFUL_SPAWN
