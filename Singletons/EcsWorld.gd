extends Node

var game_time: float = 0.0

var _next_entity_id: int = 0

var positions: Dictionary = {}
var levels: Dictionary = {}
var workers: Dictionary = {}
var fsms: Dictionary = {}
var inventories: Dictionary = {}
var productions: Dictionary = {}
var desks: Dictionary = {}
var warehouses: Dictionary = {}
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
    
    spawn_surface_plots()

    #var desk_id: int = create_entity()
    #var desk_pos = PositionComponent.new(Vector2(100, 300))
    #var desk_level = LevelComponent.new(1)
    #add_component(desk_id, DeskComponent.new())
    #add_component(desk_id, desk_pos)
    #add_component(desk_id, desk_level)
    #print("Spawned Desk (ID: %s)" % desk_id)
#
    #var worker_id: int = create_entity()
    #var worker_comp = WorkerComponent.new(
      #PlayerResources.upgrade_data["worker_speed"].current_value, 
      #PlayerResources.upgrade_data["worker_capacity"].current_value, 
      #desk_id)
    #var fsm_comp = WorkerFSMComponent.new()
    #fsm_comp.current_state = WorkerComponents.WorkerState.IDLE
    #var worker_pos = PositionComponent.new(Vector2(300, 300))
    #var worker_level = LevelComponent.new(-1)
    #var inventory = InventoryComponent.new([])
#
    #add_component(worker_id, worker_comp)
    #add_component(worker_id, fsm_comp)
    #add_component(worker_id, worker_pos)
    #add_component(worker_id, worker_level)
    #add_component(worker_id, inventory)
    #print("Spawned Worker (ID: %s)" % worker_id)
#
    #var turret_id = create_entity()
    #var t_comp = TurretComponent.new()
    #t_comp.fire_rate = 2.0
    #t_comp.damage = 5
#
    #var t_pos = PositionComponent.new(Vector2(600, 100))
#
    #add_component(turret_id, t_comp)
    #add_component(turret_id, t_pos)
    #add_component(turret_id, LevelComponent.new(1))
    #print("Spawned Turret (ID: %s)" % turret_id)

    spawn_new_level(-1)

func _process(delta: float) -> void:
    game_time += delta
    
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
    elif component is WarehouseComponent:
        warehouses[entity_id] = component
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
    warehouses.erase(entity_id)
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
        productions[factory_id].modified_production_time = new_time

func apply_inventory_to_all(new_capacity: int):
    for factory_id in productions:
        productions[factory_id].max_internal_inventory = new_capacity

func spawn_new_level(level_number: int):
    var depth_index = abs(level_number) - 1
    var level_y = PlayerResources.LEVEL_BASE_Y + (depth_index * PlayerResources.LEVEL_HEIGHT)
    
    print("Spawning level %s at Y=%s" % [level_number, level_y])
    
    for i in range(5):
        var plot_x = PlayerResources.PLOT_START_X + (i * PlayerResources.PLOT_SPACING)
        _spawn_plot(Vector2(plot_x, level_y), level_number)
        
    var warehouse_x = PlayerResources.PLOT_START_X + (5 * PlayerResources.PLOT_SPACING)
    _spawn_warehouse(Vector2(warehouse_x, level_y), level_number)

func _spawn_plot(pos: Vector2, level: int) -> int:
    var plot_id: int = create_entity()

    var pos_comp = PositionComponent.new(pos)
    var level_comp = LevelComponent.new(level)
    add_component(plot_id, PlotComponent.new())
    add_component(plot_id, pos_comp)
    add_component(plot_id, level_comp)
    
    return plot_id

func _spawn_warehouse(pos: Vector2, level: int):
    var warehouse_id: int = create_entity()
    var warehouse_pos = PositionComponent.new(pos)
    var warehouse_level = LevelComponent.new(level)
    add_component(warehouse_id, WarehouseComponent.new())
    add_component(warehouse_id, warehouse_pos)
    add_component(warehouse_id, warehouse_level)
    print("Spawned Warehouse (ID: %s)" % warehouse_id)

func build_factory_at_plot(plot_id: int, data: FactoryType):
    plots.erase(plot_id)
    
    var prod_comp = ProductionComponent.new()
    prod_comp.recipe_blueprint = data
    prod_comp.modified_production_time = data.production_time
    add_component(plot_id, prod_comp)
    
    Events.factory_builded.emit(plot_id)

func build_structure_at_plot(plot_id: int, data: StructureType):
    # Remove Plot
    plots.erase(plot_id)
    
    if data.category == "desk":
        var desk_comp = DeskComponent.new()
        desk_comp.max_workers = 3
        add_component(plot_id, desk_comp)
        spawn_worker_at_desk(plot_id)
    elif data.category == "turret":
        var turret_comp = TurretComponent.new()
        add_component(plot_id, turret_comp)
        pass
    
    Events.factory_builded.emit(plot_id)
        
func spawn_worker_at_desk(desk_id: int) -> bool:
    if not desks.has(desk_id): return false
    var desk: DeskComponent = desks[desk_id]
    
    # Check Capacity (Local limit per desk)
    if desk.current_workers >= desk.max_workers:
        print("Desk is full!")
        return false
        
    # Create Worker Entity
    var worker_id = create_entity()
    
    # Get Desk Position
    var desk_pos_vec = Vector2.ZERO
    if positions.has(desk_id):
        desk_pos_vec = positions[desk_id].position
    
    var worker_comp = WorkerComponent.new(
      PlayerResources.upgrade_data["worker_speed"].current_value,
      int(PlayerResources.upgrade_data["worker_capacity"].current_value),
      desk_id
    )
    
    var fsm = WorkerFSMComponent.new()
    fsm.current_state = WorkerComponents.WorkerState.IDLE
    
    var pos = PositionComponent.new(desk_pos_vec)
    
    var level_id: int = -1
    if levels.has(desk_id):
        level_id = levels[desk_id].level
        
    var level = LevelComponent.new(level_id)
    
    add_component(worker_id, worker_comp)
    add_component(worker_id, fsm)
    add_component(worker_id, pos)
    add_component(worker_id, level)
    
    # Update Desk Count
    desk.current_workers += 1
    
    return true

func spawn_surface_plots():
    var center_x = PlayerResources.BUNKER_ENTRANCE_X
    var ground_y = PlayerResources.SURFACE_GROUND_Y
    var turret = load("res://data/structures/turret.tres")
    
    var fence_offset = 32.0 
    var left = _spawn_plot(Vector2(center_x - fence_offset, ground_y), 0)
    var right = _spawn_plot(Vector2(center_x + fence_offset, ground_y), 0)
    build_structure_at_plot(left, turret)
    build_structure_at_plot(right, turret)
    
    print("Spawned Bunker Hardpoints at +/- %s" % fence_offset)
