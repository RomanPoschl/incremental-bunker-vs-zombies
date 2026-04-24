extends Node

@onready var anim_player: AnimationPlayer = $CanvasLayer/AnimationPlayer
@onready var color_rect: ColorRect = $CanvasLayer/ColorRect

var is_transitioning: bool = false

func change_scene(target_path: String):
    if is_transitioning:
        return
    is_transitioning = true
    color_rect.visible = true
    
    color_rect.mouse_filter = Control.MOUSE_FILTER_STOP
    anim_player.play("fade_in")
    await anim_player.animation_finished
    
    get_tree().change_scene_to_file(target_path)
    
    anim_player.play("fade_out")
    await anim_player.animation_finished
    
    color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
    is_transitioning = false
    color_rect.visible = false
