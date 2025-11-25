extends Button

var upgrade_id: String

func setup(id: String):
    upgrade_id = id
    var data = PlayerResources.upgrade_data[id]
    
    if data.icon:
        $TextureRect.texture = data.icon
        
    if data.max_level > 0:
        $LevelLabel.text = "%d/%d" % [data.level, data.max_level]
    else:
        $LevelLabel.text = "%d" % data.level # Infinite
        
    if not PlayerResources.is_upgrade_available(id) and not data.is_unlocked:
        modulate = Color(0.5, 0.5, 0.5)
        
    pressed.connect(_on_pressed)
    
func _on_pressed():
    Events.tech_node_clicked.emit(upgrade_id, self.position)
