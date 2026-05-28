/datum/ai_agent
	// PLAN_TYPE_HANDS etc
	var/list/plan_types = list()

	// (PLAN_TYPE = (/ai_task = weight)) assoc list
	var/list/current_desires = list(null = list())
	// (PLAN_TYPE = /ai_task) assoc list
	var/list/current_goals = list()

	// (PLAN_TYPE = (/ai_task = weight)) assoc list
	var/list/current_plans = list(null = list())
	// (PLAN_TYPE = /ai_task) assoc list
	var/list/current_tasks = list()

	// (PLAN_TYPE = NUM) assoc list, world timestamps which tell us when to allow acting on behalf of the next queued task by type
	var/list/plan_cooldowns = list(null = 0)

	// (BELIEF_KEY = DATA) assoc list
	var/list/beliefs = list()

	var/datum/ai_director/director
	var/atom/movable/holder

/datum/ai_agent/process(delta_time)
	build_desires()
	queue_goals()
	build_plans()
	queue_tasks()
	do_tasks()


/datum/ai_agent/proc/build_desires()
	var/list/goals_to_parse = list() 
	if(director)
		goals_to_parse += get_orders()
	goals_to_parse += get_desires()
	
	var/list/new_desires = parse_tasks_weight(goals_to_parse)

	for(var/task_type in new_desires)
		sortTim(new_desires[task_type], GLOBAL_PROC_REF(cmp_numeric_asc), TRUE)

	current_desires.Cut()
	current_desires = new_desires

/datum/ai_agent/proc/get_desires()
	RETURN_TYPE(/list)
	. = list()
	for(var/datum/ai_task/goal in GLOB.ai_tasks)
		if(can_desire(goal))
			. += goal.type
	// написать штуки

/datum/ai_agent/proc/can_desire(datum/ai_task/goal)
	if(!goal.can_assign(src, null, goal))
		return FALSE
	return TRUE


/datum/ai_agent/proc/get_goals(plan_type, list/desires = current_desires)
	RETURN_TYPE(/list)
	return LAZYACCESS(current_desires, plan_type)

/datum/ai_agent/proc/get_goal(plan_type, list/desires = current_desires)
	return LAZYACCESS(get_goals(plan_type), 1)

/datum/ai_agent/proc/queue_goals(plan_type, list/plans = current_plans)
	// написать штуки

/datum/ai_agent/proc/get_current_goal(plan_type, list/plans = current_plans)
	var/list/plan = get_plan(plan_type, plans)
	return LAZYACCESS(plan, LAZYLEN(plan))


/datum/ai_agent/proc/get_orders(list/orders = director.orders)
	RETURN_TYPE(/list)
	. = list()
	if(orders)
		. += orders


/datum/ai_agent/proc/build_plans()
	for(var/plan_type in plan_types)
		build_plan(plan_type)

#define MAX_PLAN_LENGTH 100
/datum/ai_agent/proc/build_plan(plan_type)
	var/datum/ai_task/new_goal = get_goal(plan_type)
	var/list/plan = get_plan(plan_type)
	if(new_goal == get_current_goal())
		return plan
	plan.Cut()
	/*
	var/iterating_task = get_current_goal(plan_type)
	var/prev_iterated_task
	for(var/i in 1 to MAX_PLAN_LENGTH)
		if(!LAZYLEN(iterating_task))
			break
		LAZYINSERT(get_plan(plan_type), 1, iterating_task)
		prev_iterated_task = iterating_task
		var/list/possible_predicessors = GLOB.ai_tasks[iterating_task].get_predicessors(src, prev_iterated_task, new_goal)
		iterating_task = 1
								переписать штуки!!! */
#undef MAX_PLAN_LENGTH

/datum/ai_agent/proc/get_plan(plan_type, list/plans = current_plans)
	RETURN_TYPE(/list)
	return LAZYACCESS(plans, plan_type)


/datum/ai_agent/proc/do_tasks(list/tasks = current_tasks, list/plans = current_plans)
	// написать штуки

/datum/ai_agent/proc/do_task(list/tasks = current_tasks, list/plans = current_plans)
	// написать штуки

/datum/ai_agent/proc/get_task(plan_type, i = 1)
	return LAZYACCESS(get_plan(plan_type), i)

/datum/ai_agent/proc/queue_tasks()
	for(var/plan_type in plan_types)
		current_tasks[plan_type] = get_task(plan_type)


/// Converts (/ai_task) list to (PLAN_TYPE = (/ai_task = WEIGHT)) form
/datum/ai_agent/proc/parse_tasks_weight(list/tasks, datum/ai_task/next_task, datum/ai_task/goal)
	RETURN_TYPE(/list)
	. = list()
	for(var/task_type in tasks)
		var/datum/ai_task/task = GLOB.ai_tasks[task_type]
		if(!(task.plan_type in task))
			.[task.plan_type] = list()
		.[task.plan_type][task_type] = task.get_weight(src, next_task, goal)
