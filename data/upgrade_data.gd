class_name UpgradeData extends Resource

@export_group("Identity")
@export var category: String
@export var upgrade_id: String
@export var name: String
@export var icon: Texture2D
@export_multiline var description: String

@export_group("Costs & Values")
@export var base_cost: int = 100
@export var cost_multiplier: float = 1.5
@export var base_value: float = 0.0
@export var value_multiplier: float = 1.0
@export var value_additive: float = 0.0

@export_group("Limits")
@export var max_level: int = 5

var level: int = 0
var current_value: float = 0.0

func initialize():
    level = 0
    current_value = base_value

func get_cost(current_level: int) -> int:
    return int(base_cost * pow(cost_multiplier, current_level))
    
func get_effect_value(current_level: int) -> float:
    return current_level * 1.0
