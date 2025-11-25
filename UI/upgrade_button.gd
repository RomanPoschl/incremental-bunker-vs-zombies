class_name UpgradeButton extends PanelContainer

@export var upgrade_id: String

@onready var label_name: Label = $HBoxContainer/LabelName
@onready var button_buy: Button = $HBoxContainer/ButtonBuy

func _ready() -> void:
    button_buy.pressed.connect(_on_buy_pressed)
    if not PlayerResources.upgrade_data.has(upgrade_id):
        print("UpgradeButton Error: Invalid upgrade_id: %s" % upgrade_id)
        queue_free()
       
func _process(delta: float):
    var data = PlayerResources.upgrade_data[upgrade_id]
    var cost = PlayerResources.get_upgrade_cost(upgrade_id)
    
    var is_maxed = (data.max_level > 0 and data.level >= data.max_level)
    
    if is_maxed:
        label_name.text = "%s (MAX)" % data.name
        button_buy.text = "Done"
        button_buy.disabled = true
    else:
        label_name.text = "%s (%d/%d)" % [data.name, data.level, data.max_level]
        button_buy.text = "Upgrade ($%s)" % cost
        button_buy.disabled = (PlayerResources.money < cost)
       
func _on_buy_pressed():
    PlayerResources.purchase_upgrade(upgrade_id)
