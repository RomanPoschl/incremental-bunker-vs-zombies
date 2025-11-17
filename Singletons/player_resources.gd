extends Node

@export var upgrade_definitions: Array[UpgradeData] = []
var upgrade_data: Dictionary = {}

var money: int = 100

var global_ammo: Dictionary = {}

const LEVEL_BASE_Y: float = 300.0
const LEVEL_HEIGHT: float = 200.0
const PLOT_START_X: float = 200.0
const PLOT_SPACING: float = 100.0

var current_max_level: int = 1
var next_level_cost: int = 500

func _ready() -> void:
    for upgrade_res in upgrade_definitions:
        var runtime_copy: UpgradeData = upgrade_res.duplicate()
        runtime_copy.initialize()
        upgrade_data[runtime_copy.upgrade_id] = runtime_copy
        print("Loaded upgrade: %s" % runtime_copy.name)

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
    if not global_ammo.has(ammo_type):
        return false
    if global_ammo[ammo_type] >= amount:
        global_ammo[ammo_type] -= amount
        return true
    return false

func get_ammo_count(ammo_type: String) -> int:
    if global_ammo.has(ammo_type):
        return global_ammo[ammo_type]
    return 0

func purchase_new_level():
    if spend_money(next_level_cost):
        current_max_level += 1
        next_level_cost = int(next_level_cost * 2.5) # Increase cost
        
        EcsWorld.spawn_new_level(current_max_level)
        
        var new_y_pos = LEVEL_BASE_Y + (current_max_level - 1) * LEVEL_HEIGHT
        Events.level_purchased.emit(new_y_pos)

func get_upgrade_cost(upgrade_id: String) -> int:
    if not upgrade_data.has(upgrade_id): return 999999
    
    var data: UpgradeData = upgrade_data[upgrade_id]
    var cost = data.base_cost * pow(data.cost_multiplier, data.level - 1)
    return int(cost)
    
func purchase_upgrade(upgrade_id: String):
    if not upgrade_data.has(upgrade_id): return

    var data: UpgradeData = upgrade_data[upgrade_id]
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
