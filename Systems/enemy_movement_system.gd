class_name EnemyMovementSystem

var enemies: Dictionary
var positions: Dictionary

func _init():
    self.enemies = EcsWorld.enemies
    self.positions = EcsWorld.positions

func update(delta: float):
    var target_x = PlayerResources.BUNKER_ENTRANCE_X
  
    for enemy_id in enemies.keys():

        if not positions.has(enemy_id):
            continue

        var enemy: EnemyComponent = enemies[enemy_id]
        var pos: PositionComponent = positions[enemy_id]

        var direction = 0
        if pos.position.x < target_x:
            direction = 1  # Walk Right
        else:
            direction = -1 # Walk Left

        pos.position.x += direction * enemy.speed * delta
        
        if abs(pos.position.x - target_x) < 10.0:
            print("Zombie reached the bunker! OUCH!")
            EcsWorld.mark_for_destruction(enemy_id) 
