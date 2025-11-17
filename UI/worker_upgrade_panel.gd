extends PanelContainer

@export var upgrade_btn_scene: PackedScene

@onready var container: VBoxContainer = $VBoxContainer

func _ready() -> void:
  Events.open_upgrade_window.connect(open)

func open(type: String) -> void:
  
  for t in PlayerResources.upgrade_data.keys():
    var u = PlayerResources.upgrade_data[t]
    
    if u.type == type:
      var btn = upgrade_btn_scene.instantiate()
      btn.upgrade_id = u.upgrade_id
      container.add_child(btn)
  
  var close_btn := Button.new()
  close_btn.text = "CLOSE"
  close_btn.pressed.connect(close)
  container.add_child(close_btn)
  self.visible = true
  
func close() -> void:
  for ch in container.get_children():
    ch.queue_free()

  self.visible = false
