class_name NavigationSystem

var fsms: Dictionary
var positions: Dictionary
var workers: Dictionary

const ARRIVAL_DISTANCE: float = 5.0

func _init():
    self.fsms = EcsWorld.fsms
    self.positions = EcsWorld.positions
    self.workers = EcsWorld.workers


func update(delta: float):
    for worker_id in fsms:
        var fsm: WorkerFSMComponent = fsms[worker_id]

        var is_walking: bool = (
            fsm.current_state == WorkerFSMComponent.WorkerState.WALKING_TO_DESK or
            fsm.current_state == WorkerFSMComponent.WorkerState.WALKING_TO_FACTORY or
            fsm.current_state == WorkerFSMComponent.WorkerState.WALKING_TO_ELEVATOR
        )

        if not is_walking:
            continue

        if not positions.has(worker_id) or not workers.has(worker_id):
            continue

        var worker_pos: PositionComponent = positions[worker_id]
        var worker: WorkerComponent = workers[worker_id]

        if not positions.has(fsm.target_entity_id):
            fsm.current_state = WorkerFSMComponent.WorkerState.IDLE
            continue

        var target_pos: PositionComponent = positions[fsm.target_entity_id]

        var direction: Vector2 = (target_pos.position - worker_pos.position).normalized()
        var distance: float = worker_pos.position.distance_to(target_pos.position)

        if distance > ARRIVAL_DISTANCE:
            worker_pos.position += direction * worker.move_speed * delta
        else:
            worker_pos.position = target_pos.position

            match fsm.current_state:
                WorkerFSMComponent.WorkerState.WALKING_TO_FACTORY:
                    fsm.current_state = WorkerFSMComponent.WorkerState.PICKING_UP_AMMO
                WorkerFSMComponent.WorkerState.WALKING_TO_ELEVATOR:
                    fsm.current_state = WorkerFSMComponent.WorkerState.DROPPING_OFF_AMMO
                WorkerFSMComponent.WorkerState.WALKING_TO_DESK:
                    fsm.current_state = WorkerFSMComponent.WorkerState.IDLE
