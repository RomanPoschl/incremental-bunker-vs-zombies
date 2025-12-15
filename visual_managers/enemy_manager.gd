extends Node

@export var enemy_scene: PackedScene

var enemy_nodes: Dictionary = {}

var enemies: Dictionary
var positions: Dictionary

var _current_frame_ids: Dictionary = {}
var _ids_to_remove: Array = []

func _ready() -> void:
    enemies = EcsWorld.enemies
    positions = EcsWorld.positions


func _process(delta: float) -> void:
    _current_frame_ids.clear()

    for entity_id in enemies:
        _current_frame_ids[entity_id] = true

        if not positions.has(entity_id):
            continue

        var pos: PositionComponent = positions[entity_id]
        var zombie: Zombie

        if not enemy_nodes.has(entity_id):
            zombie = enemy_scene.instantiate() as Zombie
            add_child(zombie)
            zombie.sprite.play("default")
            enemy_nodes[entity_id] = zombie
        else:
            zombie = enemy_nodes[entity_id]

        zombie.position = pos.position
        _update_facing(zombie, pos.position)
        zombie.z_index = int(pos.position.y)
        
        zombie.z_index = int(pos.position.y)
        
        if EcsWorld.levels[entity_id].level == 0:
            var scale_factor = PlayerResources.get_perspective_scale(pos.position.y)
            zombie.scale = Vector2(1, 1) * scale_factor
            zombie.modulate = PlayerResources.get_perspective_modulate(pos.position.y)
        else:
            zombie.scale = Vector2(5, 5)
            zombie.modulate = Color.WHITE

    _ids_to_remove.clear()
    for entity_id in enemy_nodes:
        if not _current_frame_ids.has(entity_id):
            _ids_to_remove.append(entity_id)

    for entity_id in _ids_to_remove:
        # Create a simple "poof" or death effect here if you want!
        enemy_nodes[entity_id].queue_free()
        enemy_nodes.erase(entity_id)

func _update_facing(zombie: Zombie, current_pos: Vector2):
    var target_x = PlayerResources.BUNKER_ENTRANCE_X

    if target_x < current_pos.x:
        zombie.sprite.flip_h = true 
    elif target_x > current_pos.x:
        zombie.sprite.flip_h = false
