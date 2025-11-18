class_name FactoryType extends Resource

@export_group("Identity")
@export var id: String = "factory_id"
@export var display_name: String = "Factory Name"
@export var build_cost: int = 100
@export var texture: Texture2D

@export_group("Production Recipe")
@export var output_ammo: AmmoType
@export var output_ammo_count: int
@export var input_ammo: Dictionary[AmmoType, int]
@export var production_time: float = 0.5
@export var stack_size: int = 10
