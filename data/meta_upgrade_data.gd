class_name MetaUpgradeData extends UpgradeData

func get_cost(current_level: int) -> int:
    return int(base_cost + (current_level * cost_multiplier))
