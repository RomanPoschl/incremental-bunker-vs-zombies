@abstract
class_name WorkerStateLogic extends RefCounted

var system: WorkerActionSystem 

func _init(parent_system):
    system = parent_system

@abstract
func update(worker_id: int, fsm: WorkerFSMComponent, delta: float)

func transition_to(fsm: WorkerFSMComponent, new_state: WorkerComponents.WorkerState):
    fsm.current_state = new_state
    fsm.action_progress = 0.0
    fsm.action_total_time = 0.0

func _process_timer(fsm: WorkerFSMComponent, delta: float) -> bool:
    if fsm.action_progress == 0:
        fsm.action_total_time = system.ACTION_TIME
        fsm.action_progress = 0.001
        return false # Not done
    
    fsm.action_progress += delta
    return fsm.action_progress >= fsm.action_total_time

func walk_to(fsm: WorkerFSMComponent, target_id: int, next_state: WorkerComponents.WorkerState):
    fsm.target_entity_id = target_id
    fsm.current_state = WorkerComponents.WorkerState.WALKING
    fsm.next_state_after_walk = next_state
