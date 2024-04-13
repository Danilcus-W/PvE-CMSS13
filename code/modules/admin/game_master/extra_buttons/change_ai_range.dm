/// Allows GM's to change ai enemy detection range to their liking
/client/proc/change_ai_range()
	set name = "Change AI View Range"
	set category = "Game Master.Extras"

	if(!admin_holder || !check_rights(R_MOD, FALSE))
		return

	var/new_range = tgui_input_number(mob, "New view range?", "AI view range", GLOB.xeno_ai_range, 100, world.view)
	if(!new_range)
		return

	GLOB.xeno_ai_range = new_range
	message_admins("[src] has changed xeno AI view range to [GLOB.xeno_ai_range] turfs globally.")

GLOBAL_VAR_INIT(xeno_ai_range, 16)
