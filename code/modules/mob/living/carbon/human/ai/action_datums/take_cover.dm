/datum/ai_action/take_cover
	name = "Take Cover"
	action_flags = ACTION_USING_LEGS

/datum/ai_action/take_cover/get_weight(datum/human_ai_brain/brain)
	if(!brain.current_cover)
		return 0

	if(brain.hold_position)
		return 0

	var/cover_distance_check = (get_dist(brain.tied_human, brain.current_target) <= brain?.gun_data?.minimum_range)
	if(brain.in_cover && (!brain.current_target || !brain.gun_data || cover_distance_check))
		return 0

	return 15

/datum/ai_action/take_cover/trigger_action()
	. = ..()

	var/turf/current_cover = brain.current_cover
	if(!brain.current_cover)
		return ONGOING_ACTION_COMPLETED

	var/mob/tied_human = brain.tied_human

#if defined(TESTING) || defined(HUMAN_AI_TESTING)
	current_cover.color = "#b80505"
	current_cover.maptext = "[tied_human.real_name] | [get_dist(current_cover, tied_human)]"
#endif

	if(get_dist(current_cover, tied_human) > 0)
		if(!brain.move_to_next_turf(current_cover))
			brain.end_cover()
			return ONGOING_ACTION_COMPLETED

		if(get_dist(current_cover, tied_human) > 0)
			return ONGOING_ACTION_UNFINISHED

	brain.in_cover = TRUE

	if(brain.target_turf)
		tied_human.face_atom(brain.target_turf)

	return ONGOING_ACTION_COMPLETED
