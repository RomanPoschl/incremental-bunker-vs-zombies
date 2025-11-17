class_name WorkerComponent extends Resource

@export var move_speed: float
@export var stack_capacity: int
@export var desk_entity_id: int

func _init(in_move_speed: float, in_stack_capacity: int, in_desk_entity_id: int) -> void:
	move_speed = in_move_speed
	stack_capacity = in_stack_capacity
	desk_entity_id = in_desk_entity_id
