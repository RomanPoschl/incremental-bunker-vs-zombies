class_name ProductionComponent extends Resource

@export var factory_type: FactoryType

var current_progress: float = 0.0
var internal_inventory: int = 0 # Output Count
var current_input_count: Dictionary[AmmoType, int] = {}

var modified_production_time: float = 0.0
var modified_max_storage: int = 200
var modified_production_amount: int = 1
var modified_stack_size: int = 10

# TODO initialize from factory
func initialize(type: FactoryType):
  pass
