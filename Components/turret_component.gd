class_name TurretComponent extends Resource

@export var fire_rate: float = 1.0
@export var range_radius: float = 300.0
@export var damage: int = 5
@export var ammo_filter_id: String = ""

@export var stack_count: int = 1
@export var max_stack: int = 5

var target_id_visual: int = -1
var just_fired_frame: bool = false
var cooldown_timer: float = 0.0
