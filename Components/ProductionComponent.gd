class_name ProductionComponent extends Resource

@export var ammo_type: String
@export var production_time: float
@export var current_progress: float = 0.0
@export var production_amount: int = 1
@export var stack_size: int = 50
@export var stack_count: int = 1

var internal_inventory: int = 0

func _init(
        in_ammo_type: String,
        in_production_time: float,
        in_production_amount: int,
        in_stack_size: int,
        in_stack_count: int) -> void:
  ammo_type = in_ammo_type
  production_time = in_production_time
  production_amount = in_production_amount
  stack_size = in_stack_size
  stack_count = in_stack_count
