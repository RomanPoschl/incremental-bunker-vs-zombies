class_name StackComponent extends Resource

@export var ammo_type: AmmoType
@export var amount: int = 0

func _init(in_ammo_type: AmmoType, in_amount: int) -> void:
    ammo_type = in_ammo_type
    amount = in_amount
