/datum/uplink_item/role_restricted/minibible
	name = "Miniature Bible"
	desc = "We understand it can be difficult to carry out some of our missions. Here is some spiritual counsel in a small package."
	progression_minimum = 5 MINUTES
	cost = 1
	item = /obj/item/storage/book/bible/mini
	restricted_roles = list(JOB_CHAPLAIN, JOB_CLOWN)
