/obj/machinery/computer/rdservercontrol
	name = "R&D Server Controller"
	desc = "Manages access to research databases and consoles."
	icon_screen = "rdcomp"
	icon_keyboard = "rd_key"
	circuit = /obj/item/circuitboard/computer/rdservercontrol
	req_access = list(ACCESS_RD)

	///Connected techweb node the server is connected to.
	var/datum/techweb/stored_research

/obj/machinery/computer/rdservercontrol/Initialize(mapload, obj/item/circuitboard/C)
	. = ..()
	if(!CONFIG_GET(flag/no_default_techweb_link) && !stored_research)
		stored_research = SSresearch.science_tech

	// MONKESTATION ADDITION
	AddComponent(/datum/component/usb_port, list(
		/obj/item/circuit_component/rd_server_data,
	))

/obj/machinery/computer/rdservercontrol/multitool_act(mob/living/user, obj/item/multitool/tool)
	if(!QDELETED(tool.buffer) && istype(tool.buffer, /datum/techweb))
		stored_research = tool.buffer
		balloon_alert(user, "techweb connected")
	return TRUE

/obj/machinery/computer/rdservercontrol/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(obj_flags & EMAGGED)
		return FALSE
	obj_flags |= EMAGGED
	playsound(src, SFX_SPARKS, 75, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	balloon_alert(user, "console emagged")
	return TRUE

/obj/machinery/computer/rdservercontrol/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ServerControl", name)
		ui.open()

/obj/machinery/computer/rdservercontrol/ui_data(mob/user)
	var/list/data = list()

	data["server_connected"] = !!stored_research

	if(stored_research)
		data["logs"] += stored_research.research_logs

		for(var/obj/machinery/rnd/server/server as anything in stored_research.techweb_servers)
			data["servers"] += list(list(
				"server_name" = server,
				"server_details" = server.get_status_text(),
				"server_disabled" = server.research_disabled,
				"server_ref" = REF(server),
			))

		for(var/obj/machinery/computer/rdconsole/console as anything in stored_research.consoles_accessing)
			data["consoles"] += list(list(
				"console_name" = console,
				"console_location" = get_area(console),
				"console_locked" = console.locked,
				"console_ref" = REF(console),
			))

	return data

/obj/machinery/computer/rdservercontrol/ui_act(action, params)
	. = ..()
	if(.)
		return TRUE
	if(!allowed(usr) && !(obj_flags & EMAGGED))
		balloon_alert(usr, "access denied!")
		playsound(src, 'sound/machines/click.ogg', 20, TRUE)
		return TRUE

	switch(action)
		if("lockdown_server")
			var/obj/machinery/rnd/server/server_selected = locate(params["selected_server"]) in stored_research.techweb_servers
			if(!server_selected)
				return FALSE
			server_selected.toggle_disable(usr)
			return TRUE
		if("lock_console")
			var/obj/machinery/computer/rdconsole/console_selected = locate(params["selected_console"]) in stored_research.consoles_accessing
			if(!console_selected)
				return FALSE
			console_selected.locked = !console_selected.locked
			return TRUE

// MONKESTATION ADDITION - USB Port


/obj/item/circuit_component/rd_server_data
	display_name = "R&D Research History"
	desc = "Outputs the Research History."
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

	/// The Research History
	var/datum/port/output/history

	var/obj/machinery/computer/rdservercontrol/attached_console

/obj/item/circuit_component/rd_server_data/populate_ports()
	history = add_output_port("Research History", PORT_TYPE_TABLE)

/obj/item/circuit_component/rd_server_data/register_usb_parent(atom/movable/shell)
	. = ..()
	if(istype(shell, /obj/machinery/computer/rdservercontrol))
		attached_console = shell

/obj/item/circuit_component/rd_server_data/unregister_usb_parent(atom/movable/shell)
	attached_console = null
	return ..()

/obj/item/circuit_component/rd_server_data/get_ui_notices()
	. = ..()
	. += create_table_notices(list(
		"research",
		"cost",
		"researcher",
		"location",
	))

/obj/item/circuit_component/rd_server_data/input_received(datum/port/input/port)

	if(!attached_console || !attached_console.stored_research)
		return

	var/list/new_table = list()
	for(var/list/research_log as anything in attached_console.stored_research.research_logs)
		var/list/entry = list()
		entry["research"] = research_log["node_name"]
		entry["cost"] = research_log["node_cost"]
		entry["researcher"] = research_log["node_researcher"]
		entry["location"] = research_log["node_research_location"]
		new_table += list(entry)

	history.set_output(new_table)

// MONKESTATION ADDITION END
