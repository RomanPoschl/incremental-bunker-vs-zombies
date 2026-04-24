extends Control

@onready var new_game: Button = %NewGame
@onready var continue_game: Button = %ContinueGame

func _ready() -> void:
    if not new_game.pressed.is_connected(_on_new_game_pressed):
      new_game.pressed.connect(_on_new_game_pressed)

    
    if not continue_game.pressed.is_connected(_on_continue_pressed):
      continue_game.pressed.connect(_on_continue_pressed)

func _on_new_game_pressed():
    PlayerResources.start_new_run()
    EcsWorld.clear_entities()
    
    SceneManager.change_scene("res://game.tscn")

func _on_continue_pressed():
    SceneManager.change_scene("res://game.tscn")
