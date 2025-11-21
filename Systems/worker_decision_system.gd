class_name WorkerDecisionSystem

var fsms: Dictionary
var workers: Dictionary
var positions: Dictionary
var levels: Dictionary
var productions: Dictionary

func _init() -> void:
    self.fsms = EcsWorld.fsms
    self.workers = EcsWorld.workers
    self.positions = EcsWorld.positions
    self.levels = EcsWorld.levels
    self.productions = EcsWorld.productions

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
