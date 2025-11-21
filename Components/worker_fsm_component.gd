class_name WorkerFSMComponent extends Resource

@export var current_state: WorkerComponents.WorkerState
@export var target_entity_id: int = -1

@export var next_state_after_walk: WorkerComponents.WorkerState

@export var action_progress: float = 0.0 
@export var action_total_time: float = 0.0
