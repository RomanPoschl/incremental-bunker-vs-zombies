extends Node

var _next_entity_id: int = 0

var global_ammo: Dictionary = {}

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

var production_system: ProductionSystem
var worker_decision_system: WorkerDecisionSystem
var navigation_system: NavigationSystem
var worker_action_system: WorkerActionSystem
var cleanup_system: CleanupSystem
var turret_system: TurretSystem

func _ready() -> void:
    production_system = ProductionSystem.new()
    worker_decision_system = WorkerDecisionSystem.new()
    navigation_system = NavigationSystem.new()
    worker_action_system = WorkerActionSystem.new()
    cleanup_system = CleanupSystem.new()
    turret_system = TurretSystem.new()

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
    var worker_comp = WorkerComponent.new(75.0, 3)
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

    var zombie_id = create_entity()
    var z_comp = EnemyComponent.new()
    z_comp.max_hp = 50
    z_comp.current_hp = 50

    var z_pos = PositionComponent.new(Vector2(325, 100))

    add_component(zombie_id, z_comp)
    add_component(zombie_id, z_pos)
    add_component(zombie_id, LevelComponent.new(1))
    print("Spawned Zombie (ID: %s)" % zombie_id)

    var zombie_id2 = create_entity()
    var z_comp2 = EnemyComponent.new()
    z_comp2.max_hp = 50
    z_comp2.current_hp = 50

    var z_pos2 = PositionComponent.new(Vector2(275, 100))

    add_component(zombie_id2, z_comp2)
    add_component(zombie_id2, z_pos2)
    add_component(zombie_id2, LevelComponent.new(1))
    print("Spawned Zombie (ID: %s)" % zombie_id2)

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

    # TODO: Add ID to a recycle list

func deposit_ammo(ammo_type: String, amount: int):
    if not global_ammo.has(ammo_type):
        global_ammo[ammo_type] = 0

    global_ammo[ammo_type] += amount
    print("Banked %s %s. Total: %s" % [amount, ammo_type, global_ammo[ammo_type]])

func get_ammo_count(ammo_type: String) -> int:
    if global_ammo.has(ammo_type):
        return global_ammo[ammo_type]
    return 0

func spend_ammo(ammo_type: String, amount: int) -> bool:
    if not global_ammo.has(ammo_type):
        return false

    if global_ammo[ammo_type] >= amount:
        global_ammo[ammo_type] -= amount
        return true

    return false
