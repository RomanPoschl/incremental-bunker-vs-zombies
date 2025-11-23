extends WorkerStateLogic

func update(worker_id: int, fsm: WorkerFSMComponent, delta: float):
    if not _process_timer(fsm, delta): return

    system.execute_warehouse_withdraw_logic(worker_id)
    
    fsm.action_progress = 0.0

    system.decide_next_destination(worker_id, fsm)
