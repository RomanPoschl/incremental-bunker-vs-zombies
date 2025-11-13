class_name ProductionSystem

var productions: Dictionary
var positions: Dictionary
var levels: Dictionary

func _init() -> void:
    productions = EcsWorld.productions
    positions = EcsWorld.positions
    levels = EcsWorld.levels

func update(delta: float) -> void:
    for entity_id in productions:
        if not positions.has(entity_id) or not levels.has(entity_id):
            continue

        var prod: ProductionComponent = productions[entity_id]

        if prod.internal_inventory >= prod.stack_count * prod.stack_size:
            prod.internal_inventory = prod.stack_count * prod.stack_size
            continue

        prod.current_progress += delta

        if prod.current_progress >= prod.production_time:
            prod.current_progress -= prod.production_time
            prod.internal_inventory += prod.production_amount
