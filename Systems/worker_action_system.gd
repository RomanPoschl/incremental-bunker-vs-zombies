class_name WorkerActionSystem

const ACTION_TIME: float = 2.0

var states: Dictionary = {}

var fsms: Dictionary
var workers: Dictionary
var inventories: Dictionary
var productions: Dictionary
var positions: Dictionary
var levels: Dictionary
var warehouses: Dictionary


func _init():
    self.fsms = EcsWorld.fsms
    self.workers = EcsWorld.workers
    self.inventories = EcsWorld.inventories
    self.productions = EcsWorld.productions
    self.positions = EcsWorld.positions
    self.levels = EcsWorld.levels
    self.warehouses = EcsWorld.warehouses
    
    var StatePickup = load("res://worker/state_pickup.gd")
    var StateInsert = load("res://worker/state_insert.gd")
    var StateDropoff = load("res://worker/state_dropoff.gd")
    var StateWarehousePickup = load("res://worker/state_warehouse_pickup.gd")

    states[WorkerComponents.WorkerState.PICKING_UP] = StatePickup.new(self)
    states[WorkerComponents.WorkerState.INSERTING] = StateInsert.new(self)
    states[WorkerComponents.WorkerState.DROPPING_OFF] = StateDropoff.new(self)
    states[WorkerComponents.WorkerState.PICKING_UP_FROM_WAREHOUSE] = StateWarehousePickup.new(self)

func update(delta: float):
    for worker_id in fsms:
        var fsm: WorkerFSMComponent = fsms[worker_id]
        
        if states.has(fsm.current_state):
            states[fsm.current_state].update(worker_id, fsm, delta)

func execute_pickup_logic(worker_id: int, factory_id: int) -> bool:
    if not productions.has(factory_id): return false
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

        var amount_to_take: int = min(prod.modified_stack_size, prod.internal_inventory)

        var new_stack = StackComponent.new(prod.recipe_blueprint.output_ammo, amount_to_take)
        inventory.stacks.append(new_stack)

        prod.internal_inventory -= amount_to_take
        stacks_picked_up += 1

    prod.last_visit_time = EcsWorld.game_time
    return stacks_picked_up > 0 or not inventory.stacks.is_empty()

func execute_insert_logic(worker_id: int, factory_id: int):
    var prod: ProductionComponent = productions[factory_id]
    var recipe: FactoryType = prod.recipe_blueprint
    var inventory: InventoryComponent = inventories[worker_id]
    
    var remaining_stacks: Array[StackComponent] = []

    for stack in inventory.stacks:
        var ammo_id = stack.ammo_type.id
        var consumed = false
        
        for ingredient in recipe.ingredients:
            if ingredient.ammo_type.id == ammo_id:
                
                var current_count = prod.current_input_inventory.get(ammo_id, 0)
                var space = prod.modified_max_storage - current_count
                
                if space > 0:
                    var amount_to_add = min(space, stack.amount)
                    
                    if not prod.current_input_inventory.has(ammo_id):
                        prod.current_input_inventory[ammo_id] = 0
                    prod.current_input_inventory[ammo_id] += amount_to_add
                    
                    stack.amount -= amount_to_add
                    consumed = true
                    
                    if stack.amount > 0:
                        remaining_stacks.append(stack)
                
                break
        
        if not consumed:
            remaining_stacks.append(stack)

    inventory.stacks = remaining_stacks

func execute_dropoff_logic(worker_id: int):
    if inventories.has(worker_id):
        var inventory: InventoryComponent = inventories[worker_id]
        
        for stack in inventory.stacks:
            PlayerResources.deposit_ammo(stack.ammo_type.id, stack.amount)
            # Optional: Create floating text here
            # Events.ammo_delivered.emit(stack.amount) 
            
        inventory.stacks.clear()

func execute_warehouse_withdraw_logic(worker_id: int):
    var needed_resource = _find_needed_resource_on_level(worker_id)
    if needed_resource == null: return

    var worker: WorkerComponent = workers[worker_id]
    var inventory: InventoryComponent = inventories[worker_id]
    
    var stacks_to_take = worker.stack_capacity - inventory.stacks.size()
    
    for i in range(stacks_to_take):
        if PlayerResources.get_ammo_count(needed_resource.id) <= 0:
            break
            
        if PlayerResources.spend_ammo(needed_resource.id, 50): # 50 = stack size?
            var new_stack = StackComponent.new(needed_resource, 50)
            inventory.stacks.append(new_stack)

func worker_has_items(worker_id: int) -> bool:
    if not inventories.has(worker_id): return false
    return not inventories[worker_id].stacks.is_empty()

func find_nearest_warehouse(worker_id: int) -> int:
    if not positions.has(worker_id) or not levels.has(worker_id):
        return -1

    var worker_pos: PositionComponent = positions[worker_id]
    var worker_level: LevelComponent = levels[worker_id]

    var closest_target_id: int = -1
    var min_distance_sq: float = INF

    for target_id in warehouses:
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

func find_worker_desk(worker_id: int) -> int:
    if workers.has(worker_id):
        return workers[worker_id].desk_entity_id
    return -1

func find_factory_needing_input(worker_id: int) -> int:
    if not levels.has(worker_id): 
        return -1

    var worker_level = levels[worker_id].level
    var first_item_type = inventories[worker_id].stacks[0].ammo_type
    for factory_id in productions:
        if not levels.has(factory_id) or levels[factory_id].level != worker_level:
            continue
            
        var prod: ProductionComponent = productions[factory_id]
        var recipe: FactoryType = prod.recipe_blueprint
        
        if not recipe.ingredients.is_empty():
            for ingredient in recipe.ingredients:
                if ingredient.ammo_type == first_item_type:
                    if prod.has_input_space(first_item_type.id): 
                        return factory_id 
                        
    return -1

func decide_next_destination(worker_id: int, fsm: WorkerFSMComponent):
    if not worker_has_items(worker_id):
        var desk_id = find_worker_desk(worker_id)
        _start_walking(fsm, desk_id, WorkerComponents.WorkerState.IDLE)
        return

    var target_factory = find_factory_needing_input(worker_id)
    
    if target_factory != -1:
        # Yes! A factory needs this. Go feed it.
        _start_walking(fsm, target_factory, WorkerComponents.WorkerState.INSERTING)
    else:
        # No factory needs this. Sell it at the warehouse.
        var warehouse = find_nearest_warehouse(worker_id)
        _start_walking(fsm, warehouse, WorkerComponents.WorkerState.DROPPING_OFF)

func assign_next_job_or_go_home(worker_id: int, fsm: WorkerFSMComponent):
    var best_factory_id: int = -1
    var highest_score: float = -INF
    
    if not positions.has(worker_id):
        _start_walking(fsm, find_worker_desk(worker_id), WorkerComponents.WorkerState.IDLE)
        return
    var worker_pos = positions[worker_id]
    var worker_level: LevelComponent = levels[worker_id]
    
    for factory_id in productions:
        var prod = productions[factory_id]
        
        var factory_level: LevelComponent = levels[factory_id]
        if factory_level.level != worker_level.level: 
          continue
        
        if not prod.production_ready: continue
        
        var factory_pos = positions[factory_id]
        var dist = worker_pos.position.distance_to(factory_pos.position)
        var score = -dist # Prefer closer
        
        var time_ignored = EcsWorld.game_time - prod.last_visit_time
        score += time_ignored * 50.0
        
        if not prod.recipe_blueprint.ingredients.is_empty():
            score += 2000.0
            
        if score > highest_score:
            highest_score = score
            best_factory_id = factory_id
    
    if best_factory_id != -1:
        _start_walking(fsm, best_factory_id, WorkerComponents.WorkerState.PICKING_UP)
    else:
        var desk_id = find_worker_desk(worker_id)
        _start_walking(fsm, desk_id, WorkerComponents.WorkerState.IDLE)

func _start_walking(fsm: WorkerFSMComponent, target_id: int, next_state: int):
    fsm.target_entity_id = target_id
    fsm.current_state = WorkerComponents.WorkerState.WALKING
    fsm.next_state_after_walk = next_state

func _find_needed_resource_on_level(worker_id: int) -> AmmoType:
    var worker_level = levels[worker_id].level
    
    for factory_id in productions:
        if levels[factory_id].level != worker_level: continue
        
        var prod = productions[factory_id]
        var recipe = prod.recipe_blueprint
        
        if recipe.ingredients.is_empty(): continue
        
        for ingredient in recipe.ingredients:
            if prod.has_input_space(ingredient.ammo_type.id):
                if PlayerResources.get_ammo_count(ingredient.ammo_type) > 0:
                    return ingredient.ammo_type
    return null
