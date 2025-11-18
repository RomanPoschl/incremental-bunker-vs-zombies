class_name InventoryComponent extends Resource

@export var stacks: Array[StackComponent] = []

func _init(in_stacks: Array[StackComponent]) -> void:
  stacks = in_stacks
