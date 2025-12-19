extends Node

@export var upgrade_definitions: Array[UpgradeData] = []
var upgrade_data: Dictionary = {}
var tech_tree_data: Dictionary = {}

@export var all_ammo_types: Array[AmmoType] = []
var ammo_db = {}

@export var all_factory_types: Array[FactoryType] = []
var factory_db = {}

@export var all_structure_types: Array[StructureType] = []
var structure_db = {}

var money: int = 0
var research_points: int = 0

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
        
        if runtime_copy is TechTreeUpgradeData:
          tech_tree_data[runtime_copy.upgrade_id] = runtime_copy
        else:
          upgrade_data[runtime_copy.upgrade_id] = runtime_copy
        print("Loaded upgrade: %s" % runtime_copy.name)
        
    load_game()
    money = get_start_money()
    print("Game Started. Money set to: %s (Base 500 + Bonus)" % money)
    
    for ammo in all_ammo_types:
        ammo_db[ammo.id] = ammo
        print("Loaded ammo type: %s" % ammo.id)
        
    for factory in all_factory_types:
        factory_db[factory.id] = factory
        print("Loaded factory type: %s" % factory.id)
        
    for structure in all_structure_types:
        structure_db[structure.id] = structure
        print("Loaded structure type: %s" % structure.id)
        
    # --- DEBUG TEST ---
    print("--- META SYSTEM CHECK ---")
    print("Current Research Points: ", research_points)
    
    # Give ourselves cheat points to test buying
    research_points = 100 
    print("Cheated Points: ", research_points)
    
    # Try to buy Trust Fund
    print("Buying Trust Fund...")
    purchase_upgrade("meta_start_money") 
    
    # Check if it worked
    var trust_fund = upgrade_data["meta_start_money"]
    print("Trust Fund Level: ", trust_fund.level)
    print("Next Run Start Money: ", get_start_money()) # We need to make this function next!

    # Try to buy Concrete
    print("Buying meta_bunker_hp...")
    purchase_upgrade("meta_bunker_hp") 
    
    # Check if it worked
    var meta_bunker_hp = upgrade_data["meta_bunker_hp"]
    print("meta_bunker_hp: ", meta_bunker_hp.level)
    print("Next Run meta_bunker_hp: ", get_max_bunker_hp())

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

func get_upgrade_cost(upgrade_id: String) -> int:
    if not upgrade_data.has(upgrade_id): return 999999
    
    var data: UpgradeData = upgrade_data[upgrade_id]
    return data.get_cost(data.level)
    
func purchase_upgrade(upgrade_id: String):
    if not upgrade_data.has(upgrade_id): return
    var data: UpgradeData = upgrade_data[upgrade_id]
    
    # 1. Check Max Level
    if data.max_level != -1 and data.level >= data.max_level:
        print("Upgrade %s is already at max level!" % data.name)
        return
    
    var cost = get_upgrade_cost(upgrade_id)
    var purchased = false
    
    # 2. DECIDE CURRENCY BASED ON TYPE
    if data is MetaUpgradeData:
        # Meta Upgrades cost Research Points
        if research_points >= cost:
            research_points -= cost
            purchased = true
            # Auto-save when buying meta items
            save_game() 
    else:
        # Normal/Tech Upgrades cost Money
        if spend_money(cost):
            purchased = true
            
    # 3. APPLY UPGRADE
    if purchased:
        data.level += 1
        
        # Recalculate Value
        if data.value_multiplier != 1.0:
            data.current_value *= data.value_multiplier
        if data.value_additive != 0.0:
            data.current_value += data.value_additive
            
        Events.upgrade_purchased.emit(upgrade_id, data.current_value)
        print("Purchased %s (Lvl %s). New value: %s" % [data.name, data.level, data.current_value])
    else:
        print("Not enough currency for %s" % data.name)

const SAVE_PATH = "user://savegame.json"

func save_game():
    var save_dict = {
        "research_points": research_points,
        "meta_levels": {}
    }
    
    for id in upgrade_data:
        var data = upgrade_data[id]
        if data is MetaUpgradeData:
            save_dict["meta_levels"][id] = data.level
            
    var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if file:
        file.store_string(JSON.stringify(save_dict))
        print("Game Saved.")

func load_game():
    if not FileAccess.file_exists(SAVE_PATH):
        return # No save file
        
    var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
    if file:
        var json = JSON.new()
        var parse_result = json.parse(file.get_as_text())
        if parse_result == OK:
            var data = json.get_data()
            research_points = data.get("research_points", 0)
            var loaded_levels = data.get("meta_levels", {})
            for id in loaded_levels:
                if upgrade_data.has(id):
                    var upgrade = upgrade_data[id]
                    upgrade.level = int(loaded_levels[id])
                    upgrade.current_value = upgrade.base_value + (upgrade.value_additive * upgrade.level)
                    print("Loaded Meta Upgrade %s at Level %s" % [id, upgrade.level])

func get_start_money() -> int:
    var base = 500 # Default
    if upgrade_data.has("meta_start_money"):
        base += int(upgrade_data["meta_start_money"].current_value)
    return base

func get_max_bunker_hp() -> int:
    var base = 100
    if upgrade_data.has("meta_bunker_hp"):
        base += int(upgrade_data["meta_bunker_hp"].current_value)
    return base
    
func start_new_run():
    money = get_start_money() 
    
    ammo_inventory.clear()
    factory_inventory.clear()
    structure_inventory.clear()
    
    for id in upgrade_data:
        var upgrade = upgrade_data[id]
        if not (upgrade is MetaUpgradeData):
            upgrade.level = 0
            upgrade.current_value = upgrade.base_value 
    
    print("Run Reset! Money: %s" % money)
