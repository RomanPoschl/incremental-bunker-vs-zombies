class_name EnemySpawnerSystem

var spawn_timer: float = 0.0
var spawn_interval: float = 5.0

var spawn_x: float = 1200.0
var spawn_y_min: float = 100.0
var spawn_y_max: float = 150.0

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
    
    var z_pos = PositionComponent.new(Vector2(spawn_x, randf_range(spawn_y_min, spawn_y_max)))
    var z_level = LevelComponent.new(1)
    
    EcsWorld.add_component(zombie_id, z_comp)
    EcsWorld.add_component(zombie_id, z_pos)
    EcsWorld.add_component(zombie_id, z_level)
    
    print("Spawned new Zombie (ID: %s)" % zombie_id)
