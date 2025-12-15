class_name FenceMiddle extends Sprite2D

func _ready():
    Events.bunker_damaged.connect(_on_bunker_damaged)

func _on_bunker_damaged(_current_hp: int):
    var tween = create_tween()
    
    tween.tween_property(self, "scale", Vector2(1.1, 0.9), 0.05).set_trans(Tween.TRANS_BOUNCE)
    tween.parallel().tween_property(self, "modulate", Color(1, 0.5, 0.5), 0.05)
    
    tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1).set_trans(Tween.TRANS_SPRING)
    tween.parallel().tween_property(self, "modulate", Color.WHITE, 0.1)
