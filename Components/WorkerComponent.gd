class_name WorkerComponent extends Resource

@export var desk_entity_id: int = -1
@export var move_speed: float
@export var stack_capacity: int

func _init(in_desk_entity_id: int, in_move_speed: float, in_stack_capacity: int) -> void:
  desk_entity_id = in_desk_entity_id
  move_speed = in_move_speed
  stack_capacity = in_stack_capacity
