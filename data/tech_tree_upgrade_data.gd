class_name TechTreeUpgradeData extends UpgradeData

@export_group("Tech Tree Requirements")
@export var prerequisite: UpgradeData
@export var grid_position: Vector2i
@export var is_unlocked: bool = false
