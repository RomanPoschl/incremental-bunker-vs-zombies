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
        var recipe = prod.factory_type

        if prod.internal_inventory >= prod.modified_max_storage:
            prod.internal_inventory = prod.modified_max_storage
            continue
            
        if not recipe.input_ammo.is_empty():
            var has_enough_ingredients = false
            for k in recipe.input_ammo.keys():
                var ammo = recipe.input_ammo[k]
                has_enough_ingredients = prod.current_input_count[k] >= ammo
                
                if not has_enough_ingredients:
                  break
            
            if not has_enough_ingredients:
                continue
                    

        prod.current_progress += delta

        if prod.current_progress >= prod.modified_production_time:
            prod.current_progress -= prod.modified_production_time
            
            if not recipe.input_ammo.is_empty():
                prod.current_input_count -= recipe.input_count
          
            prod.internal_inventory += prod.modified_production_amount
