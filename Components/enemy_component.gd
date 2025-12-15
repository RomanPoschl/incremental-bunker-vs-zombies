class_name EnemyComponent extends Resource

@export var max_hp: int = 10
@export var current_hp: int = 10
@export var speed: float = 20.0
@export var money_reward: int = 5

@export var damage: int = 5
@export var attack_cooldown: float = 1.0 # Seconds between hits
var current_cooldown: float = 0.0
