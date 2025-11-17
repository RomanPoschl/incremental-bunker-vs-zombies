extends Node

var _next_entity_id: int = 0

var positions: Dictionary = {}
var levels: Dictionary = {}
var workers: Dictionary = {}
var fsms: Dictionary = {}
var inventories: Dictionary = {}
var productions: Dictionary = {}
var desks: Dictionary = {}
var elevators: Dictionary = {}
var destroy_tags: Dictionary = {}
var enemies: Dictionary = {}
var turrets: Dictionary = {}
var plots: Dictionary = {}

var production_system: ProductionSystem
var worker_decision_system: WorkerDecisionSystem
var navigation_system: NavigationSystem
var worker_action_system: WorkerActionSystem
var cleanup_system: CleanupSystem
var turret_system: TurretSystem
var enemy_movement_system: EnemyMovementSystem
var enemy_spawner_system: EnemySpawnerSystem

func _ready() -> void:
    production_system = ProductionSystem.new()
    worker_decision_system = WorkerDecisionSystem.new()
    navigation_system = NavigationSystem.new()
    worker_action_system = WorkerActionSystem.new()
    cleanup_system = CleanupSystem.new()
    turret_system = TurretSystem.new()
    enemy_movement_system = EnemyMovementSystem.new()
    enemy_spawner_system = EnemySpawnerSystem.new()
    
    Events.upgrade_purchased.connect(_on_upgrade_purchased)

    var desk_id: int = create_entity()
    var desk_pos = PositionComponent.new(Vector2(100, 300))
    var desk_level = LevelComponent.new(1)
    add_component(desk_id, DeskComponent.new())
    add_component(desk_id, desk_pos)
    add_component(desk_id, desk_level)
    print("Spawned Desk (ID: %s)" % desk_id)

    var elevator_id: int = create_entity()
    var elev_pos = PositionComponent.new(Vector2(500, 300))
    var elev_level = LevelComponent.new(-1)
    add_component(elevator_id, ElevatorComponent.new())
    add_component(elevator_id, elev_pos)
    add_component(elevator_id, elev_level)
    print("Spawned Elevator (ID: %s)" % elevator_id)

    var factory_id: int = create_entity()
    var prod_comp = ProductionComponent.new("basic_bullet", 10, 1, 50, 200)
    var fact_pos = PositionComponent.new(Vector2(300, 300))
    var fact_level = LevelComponent.new(-1)
    add_component(factory_id, prod_comp)
    add_component(factory_id, fact_pos)
    add_component(factory_id, fact_level)
    print("Spawned Factory (ID: %s)" % factory_id)

    var worker_id: int = create_entity()
    var worker_comp = WorkerComponent.new(
      PlayerResources.upgrade_data["worker_speed"].current_value, 
      PlayerResources.upgrade_data["worker_capacity"].current_value, 
      desk_id)
    var fsm_comp = WorkerFSMComponent.new(WorkerFSMComponent.WorkerState.IDLE)
    var worker_pos = PositionComponent.new(Vector2(300, 300))
    var worker_level = LevelComponent.new(-1)

    add_component(worker_id, worker_comp)
    add_component(worker_id, fsm_comp)
    add_component(worker_id, worker_pos)
    add_component(worker_id, worker_level)
    print("Spawned Worker (ID: %s)" % worker_id)

    var turret_id = create_entity()
    var t_comp = TurretComponent.new()
    t_comp.ammo_type = "basic_bullet"
    t_comp.fire_rate = 2.0
    t_comp.damage = 5

    var t_pos = PositionComponent.new(Vector2(600, 100))

    add_component(turret_id, t_comp)
    add_component(turret_id, t_pos)
    add_component(turret_id, LevelComponent.new(1))
    print("Spawned Turret (ID: %s)" % turret_id)

    spawn_new_level(1)

func _process(delta: float) -> void:
    if production_system:
        production_system.update(delta)

    if worker_decision_system:
        worker_decision_system.update(delta)

    if navigation_system:
        navigation_system.update(delta)

    if worker_action_system:
        worker_action_system.update(delta)

    if turret_system:
        turret_system.update(delta)

    if enemy_movement_system:
        enemy_movement_system.update(delta)

    if enemy_spawner_system:
        enemy_spawner_system.update(delta)

    if cleanup_system:
        cleanup_system.update()


func create_entity() -> int:
    var new_id = _next_entity_id
    _next_entity_id += 1
    return new_id

func add_component(entity_id: int, component: Resource) -> void:
    if component is PositionComponent:
        positions[entity_id] = component
    elif component is LevelComponent:
        levels[entity_id] = component
    elif component is WorkerComponent:
        workers[entity_id] = component
    elif component is WorkerFSMComponent:
        fsms[entity_id] = component
    elif component is InventoryComponent:
        inventories[entity_id] = component
    elif component is ProductionComponent:
        productions[entity_id] = component
    elif component is DeskComponent:
        desks[entity_id] = component
    elif component is ElevatorComponent:
        elevators[entity_id] = component
    elif component is DestroyComponent:
        destroy_tags[entity_id] = component
    elif component is EnemyComponent:
        enemies[entity_id] = component
    elif component is TurretComponent:
        turrets[entity_id] = component
    elif component is PlotComponent:
        plots[entity_id] = component
    else:
        push_warning("Unknown component type added: %s" % component.get_class())

func mark_for_destruction(entity_id: int) -> void:
    if not destroy_tags.has(entity_id):
        add_component(entity_id, DestroyComponent.new())

func destroy_entity_now(entity_id: int):
    positions.erase(entity_id)
    levels.erase(entity_id)
    workers.erase(entity_id)
    fsms.erase(entity_id)
    inventories.erase(entity_id)
    productions.erase(entity_id)
    desks.erase(entity_id)
    elevators.erase(entity_id)
    destroy_tags.erase(entity_id)
    enemies.erase(entity_id)
    turrets.erase(entity_id)
    plots.erase(entity_id)
    destroy_tags.erase(entity_id)


func _on_upgrade_purchased(upgrade_id: String, new_value):
    match upgrade_id:
        "worker_speed":
            apply_worker_speed_to_all(new_value)
        "worker_capacity":
            apply_worker_capacity_to_all(new_value)
        "production_speed":
            apply_production_speed_to_all(new_value)
        "factory_inventory":
            apply_inventory_to_all(int(new_value))
        _:
            pass # Unknown upgrade

func apply_worker_speed_to_all(new_worker_speed: float) -> void:
    for worker_id in workers:
        var worker: WorkerComponent = workers[worker_id]
        worker.move_speed = new_worker_speed

func apply_worker_capacity_to_all(new_capacity: int):
    for worker_id in workers:
        workers[worker_id].stack_capacity = int(new_capacity) # Ensure it's an int

func apply_production_speed_to_all(new_time: float):
    for factory_id in productions:
        productions[factory_id].production_time = new_time

func apply_inventory_to_all(new_capacity: int):
    for factory_id in productions:
        productions[factory_id].max_internal_inventory = new_capacity

func spawn_new_level(level_number: int):
    var level_y = PlayerResources.LEVEL_BASE_Y + (level_number - 1) * PlayerResources.LEVEL_HEIGHT
    
    print("Spawning 6 plots for level %s at Y=%s" % [level_number, level_y])
    
    for i in range(6):
        var plot_x = PlayerResources.PLOT_START_X + (i * PlayerResources.PLOT_SPACING)
        _spawn_plot(Vector2(plot_x, level_y), level_number)
        
func _spawn_plot(pos: Vector2, level: int):
    var plot_id: int = create_entity()

    var pos_comp = PositionComponent.new(pos)
    var level_comp = LevelComponent.new(level)
    add_component(plot_id, PlotComponent.new())
    add_component(plot_id, pos_comp)
    add_component(plot_id, level_comp)
