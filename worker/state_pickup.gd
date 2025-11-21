extends WorkerStateLogic

func update(worker_id: int, fsm: WorkerFSMComponent, delta: float):
    if not _process_timer(fsm, delta): return

    var success = system.execute_pickup_logic(worker_id, fsm.target_entity_id)
    
    fsm.action_progress = 0.0
    
    if success:
        var next_factory = system.find_factory_needing_input(worker_id)
        
        if next_factory != -1:
            walk_to(fsm, next_factory, WorkerComponents.WorkerState.INSERTING)
        else:
            var warehouse = system.find_nearest_warehouse(worker_id)
            walk_to(fsm, warehouse, WorkerComponents.WorkerState.DROPPING_OFF)
    else:
        var desk = system.find_worker_desk(worker_id)
        walk_to(fsm, desk, WorkerComponents.WorkerState.IDLE)
