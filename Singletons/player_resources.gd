extends Node

@export var upgrade_definitions: Array[UpgradeData] = []
var upgrade_data: Dictionary = {}

@export var all_ammo_types: Array[AmmoType] = []
var ammo_db = {}

@export var all_factory_types: Array[FactoryType] = []
var factory_db = {}

@export var all_structure_types: Array[StructureType] = []
var structure_db = {}

var money: int = 10000

var bunker_max_health: int = 100
var bunker_health: int = 100

var global_ammo: Dictionary = {}

const SURFACE_GROUND_Y: float = 0
const BUNKER_ENTRANCE_X: float = 0

const ROW_HEIGHT: float = 5.0  # Vertical distance between lanes
const ROW_COUNT: int = 5        # How many lanes deep
const SPAWN_DISTANCE: float = 500.0 # How far left/right zombies spawn

const LEVEL_BASE_Y: float = 96.0
const LEVEL_HEIGHT: float = 96.0
const PLOT_START_X: float = -(5.0 * PLOT_SPACING)
const PLOT_SPACING: float = 96.0

const MIN_SCALE: float = 0.75 # Back row is 75% size
const MAX_SCALE: float = 1.0  # Front row is 100% size

var current_max_level: int = -1
var next_level_cost: int = 500

func _ready() -> void:
    for upgrade_res in upgrade_definitions:
        var runtime_copy: UpgradeData = upgrade_res.duplicate()
        runtime_copy.initialize()
        upgrade_data[runtime_copy.upgrade_id] = runtime_copy
        print("Loaded upgrade: %s" % runtime_copy.name)
        
    for ammo in all_ammo_types:
        ammo_db[ammo.id] = ammo
        print("Loaded ammo type: %s" % ammo.id)
        
    for factory in all_factory_types:
        factory_db[factory.id] = factory
        print("Loaded factory type: %s" % factory.id)
        
    for structure in all_structure_types:
        structure_db[structure.id] = structure
        print("Loaded structure type: %s" % structure.id)

func add_money(amount: int) -> void:
    money += amount

func spend_money(amount: int) -> bool:
    if money >= amount:
        money -= amount
        return true
    return false

func deposit_ammo(ammo_type: String, amount: int):
    if not global_ammo.has(ammo_type):
        global_ammo[ammo_type] = 0
    global_ammo[ammo_type] += amount

func spend_ammo(ammo_type: String, amount: int) -> bool:
    if global_ammo.has(ammo_type) and global_ammo[ammo_type] >= amount:
        global_ammo[ammo_type] -= amount
        return true

    return false

func get_ammo_count(ammo_type: String) -> int:
    if global_ammo.has(ammo_type):
        return global_ammo[ammo_type]
    return 0
    
func get_any_ammo_count() -> int:
    var bullet_count = 0
    if not global_ammo.is_empty():
        for k in global_ammo.keys():
            bullet_count += global_ammo[k]
        return bullet_count
    return 0

func purchase_new_level():
    if spend_money(next_level_cost):
        current_max_level -= 1
        next_level_cost = int(next_level_cost * 2.5) # Increase cost
        
        EcsWorld.spawn_new_level(current_max_level)
        
        var depth_index = abs(current_max_level) - 1
        var new_y_pos = LEVEL_BASE_Y + (depth_index * LEVEL_HEIGHT)
        
        Events.level_purchased.emit(new_y_pos)

func get_upgrade_cost(upgrade_id: String) -> int:
    if not upgrade_data.has(upgrade_id): return 999999
    
    var data: UpgradeData = upgrade_data[upgrade_id]
    var cost = data.base_cost * pow(data.cost_multiplier, data.level - 1)
    return int(cost)
    
func purchase_upgrade(upgrade_id: String):
    if not upgrade_data.has(upgrade_id): return

    var data: UpgradeData = upgrade_data[upgrade_id]
    
    if data.max_level != -1 and data.level >= data.max_level:
        print("Upgrade %s is already at max level!" % data.name)
        return
    
    var cost = get_upgrade_cost(upgrade_id)
    
    if spend_money(cost):
        data.level += 1
        
        if data.value_multiplier != 1.0:
            data.current_value *= data.value_multiplier
        if data.value_additive != 0.0:
            data.current_value += data.value_additive
        
        Events.upgrade_purchased.emit(upgrade_id, data.current_value)
        print("Purchased %s. New value: %s" % [data.name, data.current_value])
    else:
        print("Not enough money for %s" % data.name)

func is_upgrade_available(upgrade_id: String) -> bool:
    if not upgrade_data.has(upgrade_id): return false
    var data = upgrade_data[upgrade_id]
    
    if data.prerequisite == null:
        return true
        
    var parent_id = data.prerequisite.upgrade_id
    if upgrade_data.has(parent_id):
        var parent_data = upgrade_data[parent_id]
        return parent_data.level > 1
        
    return false

func has_ammo(ammo_id: String, amount: int) -> bool:
    return global_ammo.get(ammo_id, 0) >= amount
  
func get_perspective_scale(y_pos: float) -> float:
    var start_y = SURFACE_GROUND_Y
    var end_y = SURFACE_GROUND_Y - (ROW_COUNT * ROW_HEIGHT)
    
    var t = inverse_lerp(start_y, end_y, y_pos)
    t = clamp(t, 0.0, 1.0)
    
    return lerp(MAX_SCALE, MIN_SCALE, t)

func get_perspective_modulate(y_pos: float) -> Color:
    var start_y = SURFACE_GROUND_Y
    var end_y = SURFACE_GROUND_Y - (ROW_COUNT * ROW_HEIGHT)
    var t = inverse_lerp(start_y, end_y, y_pos)
    
    # Back rows get slightly darker (Fake Fog)
    var gray = lerp(1.0, .8, t) 
    return Color(gray, gray, gray, 1.0)
