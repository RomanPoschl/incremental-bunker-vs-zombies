class_name AmmoType extends Resource

@export_group("Identity")
@export var id: String = "ammo_id"
@export var display_name: String = "Ammo Name"
@export var icon: Texture2D

@export_group("Stats")
@export var damage: int = 5     # For turrets
@export var damage_type: String = "physical" # e.g. "freeze", "fire"
