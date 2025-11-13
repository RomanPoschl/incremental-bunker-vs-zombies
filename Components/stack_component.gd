class_name StackComponent extends Resource

@export var ammo_type: String = ""
@export var amount: int = 0

func _init(in_ammo_type: String, in_amount: int) -> void:
    ammo_type = in_ammo_type
    amount = in_amount
