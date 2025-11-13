extends Node

@export var turret_scene: PackedScene

var turret_nodes: Dictionary = {}
var turrets: Dictionary
var positions: Dictionary

var _current_frame_ids: Dictionary = {}
var _ids_to_remove: Array = []

func _ready():
    turrets = EcsWorld.turrets
    positions = EcsWorld.positions

func _process(delta: float) -> void:
    _current_frame_ids.clear()

    for entity_id in turrets:
        _current_frame_ids[entity_id] = true

        if not positions.has(entity_id): continue

        var pos = positions[entity_id]
        var turret: Turret

        if not turret_nodes.has(entity_id):
            turret = turret_scene.instantiate() as Turret
            add_child(turret)
            turret_nodes[entity_id] = turret
        else:
            turret = turret_nodes[entity_id]

        turret.position = pos.position

        # Note: We aren't visualizing shooting yet (that's next!)
        var turret_comp: TurretComponent = turrets[entity_id]

        if turret_comp.just_fired_frame:
            turret_comp.just_fired_frame = false

            if positions.has(turret_comp.target_id_visual):
                var target_pos = positions[turret_comp.target_id_visual].position
                _draw_laser(turret.position, target_pos)

    # Cleanup
    _ids_to_remove.clear()
    for entity_id in turret_nodes:
        if not _current_frame_ids.has(entity_id):
            _ids_to_remove.append(entity_id)

    for entity_id in _ids_to_remove:
        turret_nodes[entity_id].queue_free()
        turret_nodes.erase(entity_id)

func _draw_laser(start: Vector2, end: Vector2):
    var line = Line2D.new()
    line.add_point(start)
    line.add_point(end)
    line.width = 2.0
    line.default_color = Color.RED
    add_child(line)

    var tween = create_tween()
    tween.tween_property(line, "modulate:a", 0.0, 0.1) # Fade out in 0.1s
    tween.tween_callback(line.queue_free)
