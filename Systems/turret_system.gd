class_name TurretSystem

var turrets: Dictionary
var enemies: Dictionary
var positions: Dictionary

func _init() -> void:
    self.turrets = EcsWorld.turrets
    self.enemies = EcsWorld.enemies
    self.positions = EcsWorld.positions

func update(delta: float) -> void:
    for turret_id in turrets:
        var turret: TurretComponent = turrets[turret_id]

        if turret.cooldown_timer > 0:
            turret.cooldown_timer -= delta
            continue

        var ammo_res: AmmoType = null
        
        if turret.ammo_filter_id != "":
            # A. STRICT MODE
            if PlayerResources.has_ammo(turret.ammo_filter_id, 1):
                ammo_res = PlayerResources.ammo_db[turret.ammo_filter_id]
        else:
            # B. ANY MODE
            # 'global_ammo' keys are now Strings!
            for ammo_id in PlayerResources.global_ammo:
                if PlayerResources.has_ammo(ammo_id, 1):
                    # Look up the Resource using the ID
                    ammo_res = PlayerResources.ammo_db[ammo_id]
                    break

        if ammo_res == null:
            continue

        if not positions.has(turret_id):
            continue

        var turret_pos: PositionComponent = positions[turret_id]
        var target_id = _find_target_in_range(turret_pos.position, turret.range_radius)

        if target_id != -1:
            if PlayerResources.spend_ammo(ammo_res.id, 1):
                _fire_weapon(turret, turret_id, target_id, ammo_res)
                turret.cooldown_timer = 1.0 / turret.fire_rate

func _find_target_in_range(origin: Vector2, radius: float) -> int:
    var nearest_id: int = -1
    var min_dist_sq: float = radius * radius 

    for enemy_id in enemies:
        if not positions.has(enemy_id):
            continue

        var enemy_pos: PositionComponent = positions[enemy_id]
        
        var dx = abs(origin.x - enemy_pos.position.x)
        var dy = abs(origin.y - enemy_pos.position.y)
        
        var effective_dist_sq = (dx * dx) + ((dy * 0.2) * (dy * 0.2))

        if effective_dist_sq <= min_dist_sq:
            min_dist_sq = effective_dist_sq
            nearest_id = enemy_id

    return nearest_id


func _fire_weapon(turret: TurretComponent, turret_id: int, target_id: int, ammo_type: AmmoType):
    print("Turret %s PEW PEW at Zombie %s! (Ammo left: %s)" %
        [turret_id, target_id, PlayerResources.get_ammo_count(ammo_type.id)])

    # TODO: Spawn Projectile
    turret.target_id_visual = target_id
    turret.just_fired_frame = true

    var enemy: EnemyComponent = enemies[target_id]
    enemy.current_hp -= turret.damage

    if enemy.current_hp <= 0:
        print("Zombie %s destroyed!" % target_id)
        PlayerResources.add_money(enemy.money_reward)
        EcsWorld.mark_for_destruction(target_id)
