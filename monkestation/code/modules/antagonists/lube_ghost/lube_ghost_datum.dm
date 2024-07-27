/datum/antagonist/lube_ghost
	name = "Ghost of Station's Past"
	roundend_category = "Ghost of Station's Past"
	antagpanel_category = "Ghost of Station's Past"
	silent = TRUE
	give_objectives = FALSE
	show_to_ghosts = TRUE

/datum/antagonist/lube_ghost/on_gain()
	var/datum/objective/annoy_objective = new
	annoy_objective.owner = owner
	annoy_objective = "You return from the dead to ensure the station stays funny."
	objectives += annoy_objective

	if(isliving(owner.current))
		var/mob/living/basic/clown/lube/lube = owner.current

		lube.maxHealth = 400 //How could you kill a god
		lube.health = 400
		lube.melee_damage = 0 //You can't kill people! Thats evil!
		lube.obj_damage = 0
		lube.unsuitable_atmos_damage = 0
		lube.minbodytemp = TCMB
		lube.maxbodytemp = T0C + 40
		lube.alpha = 155 //Ghostly Transparency
		//Abilities & Traits added here
	. = ..()

/datum/antagonist/lube_ghost/greet()
	var/mob/living/carbon/lube = owner.current

	owner.current.playsound_local(get_turf(owner.current), 'sound/items/bikehorn.ogg',100,0, use_reverb = FALSE)
	to_chat(owner, span_boldannounce("You are the Living Lube!\nYou are an agent of chaos. Annoy the station as much as possible\n\nYou don't want to hurt anyone, but you must be as much of an annoyance as possible.\n\nHonk!"))
	owner.announce_objectives()
	switch(rand(100))
		if(100)
			lube.name = "Ghost of Pee Pee Peter"
		if(99)
			lube.name = "Carmen Miranda"
		else
			lube.name = initial(lube.name)
