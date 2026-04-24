extends Node

@export var upgrade_definitions: Array[UpgradeData] = []
var upgrade_data: Dictionary = {}
var tech_tree_data: Dictionary = {}

func _ready() -> void:
    for upgrade_res in upgrade_definitions:
        var runtime_copy: UpgradeData = upgrade_res.duplicate()
        runtime_copy.initialize()
        
        if runtime_copy is TechTreeUpgradeData:
          tech_tree_data[runtime_copy.upgrade_id] = runtime_copy
        else:
          upgrade_data[runtime_copy.upgrade_id] = runtime_copy
        print("Loaded upgrade: %s" % runtime_copy.name)
    
func start_new_run() -> void:
    for id in upgrade_data:
        var upgrade = upgrade_data[id]
        if not (upgrade is MetaUpgradeData):
            upgrade.level = 0
            upgrade.current_value = upgrade.base_value 

func save_game() -> Dictionary:
    var save_dict = {}
    for id in upgrade_data:
        var data = upgrade_data[id]
        if data is MetaUpgradeData:
            save_dict[id] = data.level
            
    return save_dict

func load_game(loaded_levels: Dictionary) -> void:
    for id in loaded_levels:
        if upgrade_data.has(id):
            var upgrade = upgrade_data[id]
            upgrade.level = int(loaded_levels[id])
            upgrade.current_value = upgrade.base_value + (upgrade.value_additive * upgrade.level)
            print("Loaded Meta Upgrade %s at Level %s" % [id, upgrade.level])

func get_upgrade_cost(upgrade_id: String) -> int:
    if not upgrade_data.has(upgrade_id): return 999999
    
    var data: UpgradeData = upgrade_data[upgrade_id]
    # Use the logic you already wrote
    var cost = data.base_cost * pow(data.cost_multiplier, data.level - 1)
    return int(cost)

func is_upgrade_available(upgrade_id: String) -> bool:
    if not upgrade_data.has(upgrade_id): return false
    var data = upgrade_data[upgrade_id]
    
    if data.prerequisite == null:
        return true
        
    var parent_id = data.prerequisite.upgrade_id
    if upgrade_data.has(parent_id):
        return upgrade_data[parent_id].level > 1
        
    return false

func purchase_upgrade(upgrade_id: String):
    if not upgrade_data.has(upgrade_id): return
    var data = upgrade_data[upgrade_id]
    
    var cost = get_upgrade_cost(upgrade_id)
    
    if PlayerResources.spend_money(cost):
        data.level += 1
        
        if data.value_multiplier != 1.0:
            data.current_value *= data.value_multiplier
        if data.value_additive != 0.0:
            data.current_value += data.value_additive
            
        Events.upgrade_purchased.emit(upgrade_id, data.current_value)
        print("Purchased %s" % data.name)
    else:
        print("Not enough money!")

func get_start_money() -> int:
    var base = 500 # Default
    if upgrade_data.has("meta_start_money"):
        base += int(upgrade_data["meta_start_money"].current_value)
    return base

func get_start_bunker_hp() -> int:
    var base = 100
    if upgrade_data.has("meta_bunker_hp"):
        base += int(upgrade_data["meta_bunker_hp"].current_value)
    return base
