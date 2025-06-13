/datum/admins/var/create_ai_humans_html = null
/datum/admins/proc/create_ai_humans(mob/user)
	if(!GLOB.gear_name_presets_list)
		return

	if(!create_ai_humans_html)
		var/equipment_presets = jointext(GLOB.gear_name_presets_list, ";")
		create_ai_humans_html = file2text('html/create_ai_humans.html')
		create_ai_humans_html = replacetext(create_ai_humans_html, "null /* object types */", "\"[equipment_presets]\"")
		create_ai_humans_html = replacetext(create_ai_humans_html, "/* href token */", RawHrefToken(forceGlobal = TRUE))

	show_browser(user, replacetext(create_ai_humans_html, "/* ref src */", "\ref[src]"), "Create AI Humans", "create_ai_humans", "size=450x640")

/client/proc/create_human_ai()
	set name = "Create Human AI"
	set category = "Game Master.HumanAI"

	if(!check_rights(R_DEBUG))
		return

	if(!SSticker.mode)
		to_chat(src, SPAN_WARNING("The round hasn't started yet!"))
		return

	if(!admin_holder)
		return

	admin_holder.create_ai_humans(usr)

/datum/admins/proc/create_ai_humans_list(href_list)
	if(SSticker?.current_state < GAME_STATE_PLAYING)
		alert("Please wait until the game has started before spawning humans")
		return

	var/atom/initial_spot = usr.loc
	var/turf/initial_turf = get_turf(initial_spot)

	var/job_name
	if (istext(href_list["create_ai_humans_list"]))
		job_name = href_list["create_ai_humans_list"]
	else
		alert("Select fewer paths, (max 1)")
		return

	var/humans_to_spawn = clamp(text2num(href_list["object_count"]), 1, 100)
	var/range_to_spawn_on = clamp(text2num(href_list["object_range"]), 0, 10)

	if(!humans_to_spawn)
		return

	var/set_squad = FALSE
	var/squad_leader = FALSE
	if(href_list["spawn_in"] == "squad")
		set_squad = TRUE
	else if(href_list["spawn_in"] == "squad_leader")
		set_squad = TRUE
		squad_leader = TRUE

	var/list/turfs = list()
	if(isnull(range_to_spawn_on))
		range_to_spawn_on = 0

	var/turf/spawn_turf
	if(range_to_spawn_on)
		for(spawn_turf in range(range_to_spawn_on, initial_turf))
			if(!spawn_turf || istype(spawn_turf, /turf/closed) || (locate(/mob/living) in spawn_turf))
				continue
			turfs += spawn_turf
	else
		turfs = list(initial_turf)

	if(!length(turfs))
		return

	var/squad_name = href_list["squad_name"]
	if(set_squad && !(squad_name in SShuman_ai.squad_id_dict))
		if(!length(squad_name))
			squad_name = "[SShuman_ai.highest_squad_id]"
			SShuman_ai.highest_squad_id++
		SShuman_ai.create_new_squad(squad_name)

	var/list/humans = list()
	var/mob/living/carbon/human/spawned_human
	for(var/i = 0 to humans_to_spawn-1)
		spawn_turf = pick(turfs)
		spawned_human = new(spawn_turf)

		if(!spawned_human.hud_used)
			spawned_human.create_hud()

		spawned_human.face_dir(usr.dir)

		spawned_human.AddComponent(/datum/component/human_ai)
		var/datum/human_ai_brain/brain = spawned_human.get_ai_brain()

		arm_equipment(spawned_human, job_name, TRUE, FALSE)
		brain.appraise_inventory() // Incase arm_equipment() is somehow overriden

		if(set_squad)
			var/datum/human_ai_squad/squad = SShuman_ai.get_squad(squad_name)
			squad.add_to_squad(brain)

			if(squad_leader)
				squad.set_squad_leader(brain)
				href_list["spawn_in"] = "squad"
				squad_leader = FALSE

		humans += spawned_human

	message_admins("[key_name_admin(usr)] created [humans_to_spawn] hAI's as [job_name] at [get_area(initial_spot)][squad_name ? ", squad [squad_name]" : null]")
