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

        if fsm.current_state != WorkerFSMComponent.WorkerState.IDLE:
            continue

        if not positions.has(worker_id) or not levels.has(worker_id):
            continue

        var worker_pos: PositionComponent = positions[worker_id]
        var worker_level: LevelComponent = levels[worker_id]

        var closest_factory_id: int = -1
        var min_distance_sq: float = INF

        for factory_id in productions:
            var prod: ProductionComponent = productions[factory_id]

            if not positions.has(factory_id) or not levels.has(factory_id):
                continue

            var factory_level: LevelComponent = levels[factory_id]
            if factory_level.level != worker_level.level:
                continue

            if prod.internal_inventory == 0:
                continue

            var factory_pos: PositionComponent = positions[factory_id]
            var dist_sq: float = worker_pos.position.distance_squared_to(factory_pos.position)

            if dist_sq < min_distance_sq:
                min_distance_sq = dist_sq
                closest_factory_id = factory_id

        if closest_factory_id != -1:
            fsm.current_state = WorkerFSMComponent.WorkerState.WALKING_TO_FACTORY
            fsm.target_entity_id = closest_factory_id
