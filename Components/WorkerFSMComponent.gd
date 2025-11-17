class_name WorkerFSMComponent extends Resource

enum WorkerState
{
    IDLE,
    WALKING_TO_FACTORY,
    PICKING_UP_AMMO,
    WALKING_TO_ELEVATOR,
    DROPPING_OFF_AMMO,
    WALKING_TO_DESK
}

@export var current_state: WorkerState
@export var target_entity_id: int = -1
@export var action_progress: float = 0.0 
@export var action_total_time: float = 0.0

func _init(in_current_state: WorkerState) -> void:
  current_state = in_current_state
