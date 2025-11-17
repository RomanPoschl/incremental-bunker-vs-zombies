extends Node

@export var worker_scene: PackedScene
@export var worker_sprite_frames: SpriteFrames

var worker_nodes: Dictionary = {}

var workers: Dictionary
var positions: Dictionary
var fsms: Dictionary
var inventories: Dictionary

var _current_ids: Dictionary = {}
var _ids_to_remove: Array = []

func _ready() -> void:
    workers = EcsWorld.workers
    positions = EcsWorld.positions
    fsms = EcsWorld.fsms
    inventories = EcsWorld.inventories

    if worker_scene == null || worker_sprite_frames == null:
        push_error("WorkerManager: something not set!")

func _process(delta: float):
    _current_ids.clear()

    for worker_id in workers:
        _current_ids[worker_id] = true # Mark this ID as "seen"

        var worker: Worker

        if not worker_nodes.has(worker_id):
            worker = _create_worker_visual(worker_id)
            worker_nodes[worker_id] = worker
        else:
            worker = worker_nodes[worker_id]

        if positions.has(worker_id) and fsms.has(worker_id):
            var pos: PositionComponent = positions[worker_id]
            var fsm: WorkerFSMComponent = fsms[worker_id]

            worker.position = pos.position
            _update_animation(worker, fsm.current_state)
            _update_facing(worker, pos.position, fsm)

            var is_carrying = inventories.has(worker_id) and not inventories[worker_id].stacks.is_empty()
            worker.ammo_box.visible = is_carrying

            worker.visible = true
            
            if fsm.action_total_time > 0:
                worker.action_progress_bar.visible = true
                worker.action_progress_bar.value = fsm.action_progress / fsm.action_total_time * 100
            else:
                worker.action_progress_bar.visible = false
        else:
            worker.visible = false

    _ids_to_remove.clear()
    for worker_id in worker_nodes:
        if not _current_ids.has(worker_id):
            _ids_to_remove.append(worker_id)

    for worker_id in _ids_to_remove:
        worker_nodes[worker_id].queue_free()
        worker_nodes.erase(worker_id)

func _create_worker_visual(worker_id: int) -> Worker:
    var worker = worker_scene.instantiate() as Worker
    add_child(worker)
    worker.sprite.play("idle")
    return worker

func _update_animation(worker: Worker, state: WorkerFSMComponent.WorkerState):
    var new_anim: String
    match state:
        WorkerFSMComponent.WorkerState.WALKING_TO_DESK, \
        WorkerFSMComponent.WorkerState.WALKING_TO_ELEVATOR, \
        WorkerFSMComponent.WorkerState.WALKING_TO_FACTORY:
            new_anim = "walk"
        _:
            new_anim = "idle"

    if worker.sprite.animation != new_anim:
        worker.sprite.play(new_anim)

func _update_facing(worker: Worker, current_pos: Vector2, fsm: WorkerFSMComponent):
    if fsm.target_entity_id == -1:
        return

    if not positions.has(fsm.target_entity_id):
        return

    var target_pos: PositionComponent = positions[fsm.target_entity_id]

    if target_pos.position.x < current_pos.x:
        worker.sprite.flip_h = true
    elif target_pos.position.x > current_pos.x:
        worker.sprite.flip_h = false
