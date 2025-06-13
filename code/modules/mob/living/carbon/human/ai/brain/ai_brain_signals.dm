/datum/human_ai_brain/proc/on_target_delete(datum/source, force)
	SIGNAL_HANDLER
	lose_target()
	target_turf = null

/datum/human_ai_brain/proc/on_target_death(datum/source)
	SIGNAL_HANDLER
	lose_target()
	target_turf = null

/datum/human_ai_brain/proc/on_target_move(atom/oldloc, dir, forced)
	SIGNAL_HANDLER
	update_target()

/datum/human_ai_brain/proc/on_human_delete(datum/source, force)
	SIGNAL_HANDLER
	tied_human = null

/datum/human_ai_brain/proc/on_species_change(datum/source, new_species)
	SIGNAL_HANDLER
	if((new_species == SPECIES_YAUTJA) || (new_species == SPECIES_ZOMBIE))
		ignore_looting = TRUE
	else
		ignore_looting = FALSE

/datum/human_ai_brain/proc/on_detection_turf_enter(datum/source, atom/movable/entering)
	SIGNAL_HANDLER
	if(tied_human.client)
		return

	if(entering == tied_human)
		return

	if(istype(entering, /obj/projectile))
		var/obj/projectile/bullet = entering

		enter_combat()

		if(length(neutral_factions))
			if(ismob(bullet.firer))
				var/mob/mob_firer = bullet.firer
				if(mob_firer.faction in neutral_factions)
					on_neutral_faction_betray(mob_firer.faction)

			else if(isdefenses(bullet.firer))
				var/obj/structure/machinery/defenses/defense_firer = bullet.firer
				for(var/faction in defense_firer.faction_group)
					if(faction in neutral_factions)
						on_neutral_faction_betray(faction)

		if(faction_check(bullet.firer))
			return

		if(get_dist(tied_human, bullet.firer) <= view_distance)
			set_target(bullet.firer)
		else
			COOLDOWN_START(src, fire_offscreen, 4 SECONDS)
			target_turf = get_turf(bullet.firer)

/datum/human_ai_brain/proc/on_move(atom/oldloc, direction, forced)
	setup_detection_radius()

	if(in_cover && (get_dist(tied_human, current_cover) > gun_data?.minimum_range))
		end_cover()

	update_target()

/datum/human_ai_brain/proc/on_shot(datum/source, damage_result, ammo_flags, obj/projectile/bullet)
	SIGNAL_HANDLER
	if(tied_human.client)
		return

	enter_combat()

	if(length(neutral_factions))
		if(ismob(bullet.firer))
			var/mob/mob_firer = bullet.firer
			if(mob_firer.faction in neutral_factions)
				on_neutral_faction_betray(mob_firer.faction)

		else if(isdefenses(bullet.firer))
			var/obj/structure/machinery/defenses/defense_firer = bullet.firer
			for(var/faction in defense_firer.faction_group)
				if(faction in neutral_factions)
					on_neutral_faction_betray(faction)

	var/distance = get_dist(tied_human, bullet.firer)
	if(distance > view_distance)
		target_turf = get_turf(bullet.firer)

	if(faction_check(bullet.firer))
		return

	if(!current_cover)
		try_cover(bullet.firer, bullet.angle)
	else if(in_cover)
		damaged_inside_cover(bullet.firer, bullet.angle)

	if(distance <= view_distance)
		set_target(bullet.firer)
	else
		COOLDOWN_START(src, fire_offscreen, 4 SECONDS)

/datum/human_ai_brain/proc/on_hit(datum/source, obj/item/attack_obj, mob/living/attacker, params)
	SIGNAL_HANDLER
	if(tied_human.client)
		return

	enter_combat()

	if(length(neutral_factions))
		if(attacker.faction in neutral_factions)
			on_neutral_faction_betray(attacker.faction)

	if(faction_check(attacker))
		return

	if(in_cover)
		damaged_inside_cover(attacker)

	set_target(attacker)

/datum/human_ai_brain/proc/on_slashed(datum/source, list/slashdata, mob/living/carbon/xenomorph/xeno)
	SIGNAL_HANDLER
	if(tied_human.client)
		return

	enter_combat()

	if(length(neutral_factions))
		if(xeno.faction in neutral_factions)
			on_neutral_faction_betray(xeno.faction)

	if(faction_check(xeno))
		return

	if(in_cover)
		damaged_inside_cover(xeno)

	set_target(xeno)
