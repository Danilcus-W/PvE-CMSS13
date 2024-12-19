/client/proc/toggle_human_ai_tweaks()
	set name = "Toggle Human AI Tweaks"
	set category = "Game Master.Flags"

	if(!admin_holder || !check_rights(R_MOD, FALSE))
		return

	if(!SSticker.mode)
		to_chat(usr, SPAN_WARNING("A mode hasn't been selected yet!"))
		return

	SSticker.mode.toggleable_flags ^= MODE_HUMAN_AI_TWEAKS
	message_admins("[src] has [MODE_HAS_TOGGLEABLE_FLAG(MODE_HUMAN_AI_TWEAKS) ? "toggled Human AI tweaks on" : "toggled Human AI tweaks off"].")
