class_name EnemySpawnerSystem

var spawn_timer: float = 0.0
var spawn_interval: float = 5.0 # Spawn a new zombie every 5 seconds

func update(delta: float):
    spawn_timer -= delta

    if spawn_timer <= 0:
        spawn_timer = spawn_interval
        _spawn_enemy()

func _spawn_enemy():
    var zombie_id = EcsWorld.create_entity()

    var z_comp = EnemyComponent.new()
    z_comp.max_hp = 50
    z_comp.current_hp = 50
    z_comp.speed = randf_range(20.0, 40.0) # Give some variety
    z_comp.money_reward = randi_range(5, 15)
    
    var side_multiplier = 1 if randf() > 0.5 else -1
    var row_index = randi() % PlayerResources.ROW_COUNT
    var spawn_x = PlayerResources.BUNKER_ENTRANCE_X + (side_multiplier * PlayerResources.SPAWN_DISTANCE)
    var spawn_y = PlayerResources.SURFACE_GROUND_Y + (row_index * PlayerResources.ROW_HEIGHT)

    var z_pos = PositionComponent.new(Vector2(spawn_x, spawn_y))
    var z_level = LevelComponent.new(0)

    EcsWorld.add_component(zombie_id, z_comp)
    EcsWorld.add_component(zombie_id, z_pos)
    EcsWorld.add_component(zombie_id, z_level)

    print("Spawned new Zombie (ID: %s)" % zombie_id)
