class_name WorkerActionSystem

var fsms: Dictionary
var workers: Dictionary
var inventories: Dictionary
var productions: Dictionary
var positions: Dictionary
var levels: Dictionary
var elevators: Dictionary

const ACTION_TIME: float = 2.0

func _init():
    self.fsms = EcsWorld.fsms
    self.workers = EcsWorld.workers
    self.inventories = EcsWorld.inventories
    self.productions = EcsWorld.productions
    self.positions = EcsWorld.positions
    self.levels = EcsWorld.levels
    self.elevators = EcsWorld.elevators


func update(delta: float):
    for worker_id in fsms:
        var fsm: WorkerFSMComponent = fsms[worker_id]

        match fsm.current_state:
            WorkerFSMComponent.WorkerState.PICKING_UP_AMMO:
                _handle_pickup(worker_id, fsm, delta)

            WorkerFSMComponent.WorkerState.DROPPING_OFF_AMMO:
                _handle_dropoff(worker_id, fsm, delta)

func _handle_pickup(worker_id: int, fsm: WorkerFSMComponent, delta: float):
    if fsm.action_progress == 0:
        if not productions.has(fsm.target_entity_id) or not workers.has(worker_id):
            _send_worker_to_desk(worker_id, fsm)
            return
        var prod: ProductionComponent = productions[fsm.target_entity_id]
        if prod.internal_inventory <= 0:
            _send_worker_to_desk(worker_id, fsm)
            return

        fsm.action_total_time = ACTION_TIME
        fsm.action_progress = 0.001
        return
  
    fsm.action_progress += delta
    
    if fsm.action_progress < fsm.action_total_time:
        return
        
    var factory_id: int = fsm.target_entity_id

    var prod: ProductionComponent = productions[factory_id]
    var worker: WorkerComponent = workers[worker_id]

    var inventory: InventoryComponent
    if not inventories.has(worker_id):
        inventory = InventoryComponent.new([])
        EcsWorld.add_component(worker_id, inventory)
    else:
        inventory = inventories[worker_id]

    var empty_slots: int = worker.stack_capacity - inventory.stacks.size()
    var stacks_picked_up: int = 0

    for i in range(empty_slots):
        if prod.internal_inventory <= 0:
            break

        var amount_to_take: int = min(prod.stack_size, prod.internal_inventory)

        var new_stack = StackComponent.new(prod.ammo_type, amount_to_take)
        inventory.stacks.append(new_stack)

        prod.internal_inventory -= amount_to_take
        stacks_picked_up += 1

    fsm.action_progress = 0.0
    fsm.action_total_time = 0.0
    if stacks_picked_up > 0 or not inventory.stacks.is_empty():
        _send_worker_to_elevator(worker_id, fsm)

func _handle_dropoff(worker_id: int, fsm: WorkerFSMComponent, delta: float):
    if fsm.action_progress == 0:
        if not inventories.has(worker_id):
            _send_worker_to_desk(worker_id, fsm)
            return
        fsm.action_total_time = ACTION_TIME
        fsm.action_progress = 0.001 
        return

    fsm.action_progress += delta

    if fsm.action_progress < fsm.action_total_time:
      return

    var inventory: InventoryComponent = inventories[worker_id]
    if inventory.stacks.is_empty():
        _send_worker_to_desk(worker_id, fsm)
        return

    for stack: StackComponent in inventory.stacks:
        PlayerResources.deposit_ammo(stack.ammo_type, stack.amount)

    inventory.stacks.clear()
    fsm.action_progress = 0.0
    fsm.action_total_time = 0.0
    _send_worker_to_desk(worker_id, fsm)

func _find_nearest_target(worker_id: int, target_pool: Dictionary) -> int:
    if not positions.has(worker_id) or not levels.has(worker_id):
        return -1

    var worker_pos: PositionComponent = positions[worker_id]
    var worker_level: LevelComponent = levels[worker_id]

    var closest_target_id: int = -1
    var min_distance_sq: float = INF

    for target_id in target_pool:
        if not positions.has(target_id) or not levels.has(target_id):
            continue
        if levels[target_id].level != worker_level.level:
            continue

        var target_pos: PositionComponent = positions[target_id]
        var dist_sq: float = worker_pos.position.distance_squared_to(target_pos.position)

        if dist_sq < min_distance_sq:
            min_distance_sq = dist_sq
            closest_target_id = target_id

    return closest_target_id

func _send_worker_to_elevator(worker_id: int, fsm: WorkerFSMComponent):
    var elevator_id: int = _find_nearest_target(worker_id, elevators)
    if elevator_id != -1:
        fsm.target_entity_id = elevator_id
        fsm.current_state = WorkerFSMComponent.WorkerState.WALKING_TO_ELEVATOR
    else:
        _send_worker_to_desk(worker_id, fsm)

func _send_worker_to_desk(worker_id: int, fsm: WorkerFSMComponent):
    if workers.has(worker_id):
        var worker: WorkerComponent = workers[worker_id]
        fsm.target_entity_id = worker.desk_entity_id
        fsm.current_state = WorkerFSMComponent.WorkerState.WALKING_TO_DESK
    else:
        fsm.current_state = WorkerFSMComponent.WorkerState.IDLE
