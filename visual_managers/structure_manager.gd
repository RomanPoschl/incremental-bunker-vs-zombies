extends Node

@export var factory_texture: PackedScene
@export var elevator_texture: PackedScene
@export var desk_texture: PackedScene

var structure_nodes: Dictionary = {}

var productions: Dictionary
var elevators: Dictionary
var desks: Dictionary
var positions: Dictionary

func _ready():
    productions = EcsWorld.productions
    elevators = EcsWorld.elevators
    desks = EcsWorld.desks
    positions = EcsWorld.positions

func _process(delta: float):
    _update_structures(productions, factory_texture, Color.RED)
    _update_structures(elevators, elevator_texture, Color.BLUE)
    _update_structures(desks, desk_texture, Color.BROWN)
    
    _handle_cleanup()


func _update_structures(pool: Dictionary, scene: PackedScene, default_color: Color):
    for entity_id in pool:
        if structure_nodes.has(entity_id):
            continue
            
        if not positions.has(entity_id):
            continue
            
        var pos = positions[entity_id]
        var instance = scene.instantiate() as Structure            
        instance.position = pos.position
        add_child(instance)
        
        structure_nodes[entity_id] = instance
        print("Spawned visual for structure ", entity_id)

func _handle_cleanup():
    var ids_to_remove = []
    for id in structure_nodes:
        var exists = productions.has(id) or elevators.has(id) or desks.has(id)
        if not exists:
            ids_to_remove.append(id)
            
    for id in ids_to_remove:
        structure_nodes[id].queue_free()
        structure_nodes.erase(id)
