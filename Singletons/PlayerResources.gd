extends Node



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
    load_game()
    money = UpgradeManager.get_start_money()
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

func has_ammo(ammo_id: String, amount: int) -> bool:
    return global_ammo.get(ammo_id, 0) >= amount

const SAVE_PATH = "user://savegame.json"

func save_game():
    var save_dict = {
        "research_points": research_points,
        "meta_levels": {}
    }
    
    save_dict["meta_levels"] = UpgradeManager.save_game()
            
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
            UpgradeManager.load_game(loaded_levels)
    
func start_new_run():
    money = UpgradeManager.get_start_money() 
    global_ammo.clear()
    UpgradeManager.start_new_run()
    print("Run Reset! Money: %s" % money)
