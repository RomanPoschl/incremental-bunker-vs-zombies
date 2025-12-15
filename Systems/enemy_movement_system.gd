class_name EnemyMovementSystem

const ATTACK_RANGE: float = 40.0

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
        
        var dist_x = abs(pos.position.x - target_x)
        
        if dist_x > ATTACK_RANGE:
            var direction = 1 if pos.position.x < target_x else -1
            pos.position.x += direction * enemy.speed * delta
            enemy.current_cooldown = 0.5
        else:
            if enemy.current_cooldown > 0:
                enemy.current_cooldown -= delta
            else:
                _perform_attack(enemy)
                enemy.current_cooldown = enemy.attack_cooldown

func _perform_attack(enemy: EnemyComponent):
    # Damage the global health
    PlayerResources.bunker_health -= enemy.damage
    Events.bunker_damaged.emit(PlayerResources.bunker_health)
    print("Bunker took damage! HP: %s" % PlayerResources.bunker_health)
    
    # Optional: Game Over Check
    if PlayerResources.bunker_health <= 0:
        print("GAME OVER! THE ZOMBIES ATE YOUR BRAINS!")
        # get_tree().reload_current_scene() # Simple restart
