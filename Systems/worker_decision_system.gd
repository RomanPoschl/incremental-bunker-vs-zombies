class_name WorkerDecisionSystem

var fsms: Dictionary
var workers: Dictionary
var positions: Dictionary
var levels: Dictionary
var productions: Dictionary
var warehouses: Dictionary

func _init() -> void:
    self.fsms = EcsWorld.fsms
    self.workers = EcsWorld.workers
    self.positions = EcsWorld.positions
    self.levels = EcsWorld.levels
    self.productions = EcsWorld.productions
    self.warehouses = EcsWorld.warehouses

func update(delta: float) -> void:
    for worker_id in fsms:
        var fsm: WorkerFSMComponent = fsms[worker_id]

        if fsm.current_state != WorkerComponents.WorkerState.IDLE:
            continue

        if not positions.has(worker_id) or not levels.has(worker_id):
            continue

        var worker_pos: PositionComponent = positions[worker_id]
        var worker_level: LevelComponent = levels[worker_id]

        var best_factory_id: int = -1
        var highest_score: float = -INF
        
        for factory_id in productions:
            var prod: ProductionComponent = productions[factory_id]
            
            if not positions.has(factory_id) or not levels.has(factory_id): continue

            var factory_level: LevelComponent = levels[factory_id]
            if factory_level.level != worker_level.level: 
              continue

            if not prod.production_ready: continue
            
            var factory_pos = positions[factory_id]
            var dist = worker_pos.position.distance_to(factory_pos.position)
            var score = -dist
            
            var recipe: FactoryType = prod.recipe_blueprint
            if not recipe.ingredients.is_empty():
                score += 2000.0
                
            var percent_full = float(prod.internal_inventory) / float(prod.modified_max_storage)
            if percent_full >= 0.9:
                score += 5000.0
            elif percent_full >= 0.5:
                score += 1000.0
                
            var time_ignored = EcsWorld.game_time - prod.last_visit_time
            var aging_score = time_ignored * 50.0
            score += aging_score
                
            if score > highest_score:
                highest_score = score
                best_factory_id = factory_id

        if best_factory_id != -1:
            fsm.current_state = WorkerComponents.WorkerState.WALKING
            fsm.next_state_after_walk = WorkerComponents.WorkerState.PICKING_UP
            fsm.target_entity_id = best_factory_id

        var supply_job = _find_supply_job(worker_id)
        
        if supply_job.factory_needs_supply:
            # We found a factory that needs ingredients!
            # Now find a warehouse on the SAME LEVEL to fetch them from.
            var warehouse_id = _find_nearest_warehouse(worker_id)
            
            if warehouse_id != -1:
                fsm.current_state = WorkerComponents.WorkerState.WALKING
                fsm.next_state_after_walk = WorkerComponents.WorkerState.PICKING_UP_FROM_WAREHOUSE
                fsm.target_entity_id = warehouse_id
                
func _find_supply_job(worker_id: int) -> Dictionary:
    if not levels.has(worker_id): 
        return { "factory_needs_supply": false, "resource_id": "" }
    var worker_level = levels[worker_id].level

    for factory_id in productions:
        if not levels.has(factory_id) or levels[factory_id].level != worker_level:
            continue

        var prod: ProductionComponent = productions[factory_id]
        var recipe: FactoryType = prod.recipe_blueprint
        
        if recipe.ingredients.is_empty(): continue
        
        for ingredient in recipe.ingredients:
            var needed_id = ingredient.ammo_type.id
            
            if prod.has_input_space(needed_id):
                if PlayerResources.get_ammo_count(needed_id) > 0: # Ideally check specific ammo type count
                     return { "factory_needs_supply": true, "resource_id": needed_id }
                    
    return { "factory_needs_supply": false, "resource_id": "" }

func _find_nearest_warehouse(worker_id: int) -> int:
    if not positions.has(worker_id) or not levels.has(worker_id):
        return -1

    var worker_pos = positions[worker_id].position
    var worker_level = levels[worker_id].level

    var closest_id = -1
    var min_dist = INF

    for warehouse_id in warehouses:
        if not levels.has(warehouse_id) or levels[warehouse_id].level != worker_level:
            continue
            
        if not positions.has(warehouse_id): continue
        
        var dist = worker_pos.distance_squared_to(positions[warehouse_id].position)
        if dist < min_dist:
            min_dist = dist
            closest_id = warehouse_id
            
    return closest_id
