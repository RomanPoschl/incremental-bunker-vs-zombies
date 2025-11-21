extends WorkerStateLogic

func update(worker_id: int, fsm: WorkerFSMComponent, delta: float):
    if not _process_timer(fsm, delta): return

    system.execute_dropoff_logic(worker_id)
    
    fsm.action_progress = 0.0

    system.assign_next_job_or_go_home(worker_id, fsm)
