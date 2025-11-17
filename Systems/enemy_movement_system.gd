class_name EnemyMovementSystem

var enemies: Dictionary
var positions: Dictionary

func _init():
    self.enemies = EcsWorld.enemies
    self.positions = EcsWorld.positions

func update(delta: float):
    for enemy_id in enemies.keys():

        if not positions.has(enemy_id):
            continue

        var enemy: EnemyComponent = enemies[enemy_id]
        var pos: PositionComponent = positions[enemy_id]

        pos.position.x -= enemy.speed * delta

        if pos.position.x < -100:
            print("Enemy %s reached the city and despawned." % enemy_id)
            EcsWorld.mark_for_destruction(enemy_id)
