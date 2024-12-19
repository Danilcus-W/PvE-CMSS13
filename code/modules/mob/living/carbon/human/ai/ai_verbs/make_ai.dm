/client/proc/make_human_ai(mob/living/carbon/human/mob in GLOB.human_mob_list)
	set name = "Make AI"
	set desc = "Add AI functionality to a human."
	set category = null

	if(!check_rights(R_DEBUG|R_ADMIN))
		return

	if(QDELETED(mob))
		return //mob is garbage collected

	if(mob.GetComponent(/datum/component/human_ai))
		to_chat(usr, SPAN_WARNING("[mob] already has an assigned AI."))
		return

	if(mob.ckey && alert("This mob is being controlled by [mob.ckey]. Are you sure you wish to add AI to it?","Make AI","Yes","No") != "Yes")
		return

	mob.AddComponent(/datum/component/human_ai)

	message_admins("[key_name_admin(usr)] assigned an AI component to [mob.real_name].")
