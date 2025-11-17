class_name UpgradeData extends Resource

@export var category: String
@export var upgrade_id: String
@export var name: String
@export var base_cost: int = 100
@export var cost_multiplier: float = 1.5
@export var base_value: float = 0.0
@export var value_multiplier: float = 1.0
@export var value_additive: float = 0.0

var level: int = 1
var current_value: float = 0.0

func initialize():
    level = 1
    current_value = base_value
