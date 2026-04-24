extends Node

@export_group("Ammo")
@export var all_ammo_types: Array[AmmoType] = []
var ammo_db: Dictionary = {}

@export_group("Factories")
@export var all_factory_types: Array[FactoryType] = []
var factory_db: Dictionary = {}

@export_group("Structures")
@export var all_structure_types: Array[StructureType] = []
var structure_db: Dictionary = {}

func _ready() -> void:
    _initialize_databases()

func _initialize_databases() -> void:
    for ammo in all_ammo_types:
        if ammo:
            ammo_db[ammo.id] = ammo
            print("DB: Indexed Ammo [%s]" % ammo.id)
            
    for factory in all_factory_types:
        if factory:
            factory_db[factory.id] = factory
            print("DB: Indexed Factory [%s]" % factory.id)
            
    for structure in all_structure_types:
        if structure:
            structure_db[structure.id] = structure
            print("DB: Indexed Structure [%s]" % structure.id)

func get_ammo(id: String) -> AmmoType:
    if ammo_db.has(id): return ammo_db[id]
    push_error("DatabaseManager: Ammo ID '%s' not found!" % id)
    return null

func get_factory(id: String) -> FactoryType:
    if factory_db.has(id): return factory_db[id]
    push_error("DatabaseManager: Factory ID '%s' not found!" % id)
    return null

func get_structure(id: String) -> StructureType:
    if structure_db.has(id): return structure_db[id]
    push_error("DatabaseManager: Structure ID '%s' not found!" % id)
    return null
