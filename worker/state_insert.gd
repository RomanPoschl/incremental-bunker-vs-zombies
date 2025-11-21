extends WorkerStateLogic

func update(worker_id: int, fsm: WorkerFSMComponent, delta: float):
    if not _process_timer(fsm, delta): return

    system.execute_insert_logic(worker_id, fsm.target_entity_id)
    
    fsm.action_progress = 0.0

    if system.worker_has_items(worker_id):
        system.decide_next_destination(worker_id, fsm)
    else:
        system.assign_next_job_or_go_home(worker_id, fsm)
