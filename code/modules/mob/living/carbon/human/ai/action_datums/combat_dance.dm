/datum/ai_action/combat_dance
	name = "Combat Dance"
	action_flags = ACTION_USING_LEGS

/datum/ai_action/combat_dance/get_weight(datum/human_ai_brain/brain)
	var/atom/movable/current_target = brain.current_target
	if(!current_target)
		return 0

	if(!brain.primary_weapon)
		return 0

	if(brain.tried_reload)
		return 0

	if(brain.hold_position)
		return 0

	if(brain.active_grenade_found)
		return 0

	if(brain.current_cover)
		return 0

	return 9

/datum/ai_action/combat_dance/trigger_action()
	. = ..()

	if(!get_weight(brain))
		return ONGOING_ACTION_COMPLETED

	for(var/direction in shuffle(GLOB.cardinals))
		if(brain.move_to_next_turf(get_step(brain.tied_human, direction)))
			break

	return ONGOING_ACTION_COMPLETED
