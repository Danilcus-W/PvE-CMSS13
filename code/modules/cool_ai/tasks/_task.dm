GLOBAL_LIST_INIT_TYPED(ai_tasks, /datum/ai_task, build_global_task_list())

/proc/build_global_task_list()
	. = list()
	for(var/type in subtypesof(/datum/ai_task))
		. += new type

/datum/ai_task
	var/plan_type = null

/datum/ai_task/proc/can_assign(datum/ai_agent/agent, datum/ai_task/next_task, datum/ai_task/goal, ...)
	if(plan_type in agent.plan_types)
		return TRUE
	return FALSE

/datum/ai_task/proc/get_predicessors(datum/ai_agent/agent, datum/ai_task/next_task, datum/ai_task/goal, ...)
	return list(
		list(/datum/ai_task) = /datum/ai_task::get_weight(agent, initial(type), goal)
		)

/datum/ai_task/proc/act(datum/ai_agent/agent, datum/ai_task/next_task, datum/ai_task/goal, ...)
	return TRUE

/datum/ai_task/proc/get_state(datum/ai_agent/agent, datum/ai_task/next_task, datum/ai_task/goal, ...)
	return 1

/datum/ai_task/proc/get_start_delay(datum/ai_agent/agent, datum/ai_task/next_task, datum/ai_task/goal, ...)
	return 0

/datum/ai_task/proc/get_end_delay(datum/ai_agent/agent, datum/ai_task/next_task, datum/ai_task/goal, ...)
	return 0

/datum/ai_task/proc/get_weight(datum/ai_agent/agent, datum/ai_task/next_task, datum/ai_task/goal, ...)
	return 0

/datum/ai_task/proc/get_predicessor(datum/ai_agent/agent, datum/ai_task/next_task, datum/ai_task/goal, ...)
	return LAZYACCESS(sortTim(get_predicessors(agent, initial(type), goal), GLOBAL_PROC_REF(cmp_numeric_asc), TRUE), 1)
