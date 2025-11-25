extends PanelContainer

@onready var title_label = $VBoxContainer/TitleLabel
@onready var icon_rect = $VBoxContainer/IconRect
@onready var desc_label = $VBoxContainer/DescLabel
@onready var cost_label = $VBoxContainer/CostLabel
@onready var buy_button = $VBoxContainer/HBoxContainer/BuyButton
@onready var close_button = $VBoxContainer/HBoxContainer/CloseButton

var current_upgrade_id: String = ""

func _ready():
    close_button.pressed.connect(func(): visible = false)
    buy_button.pressed.connect(_on_buy_pressed)

func open(upgrade_id: String, position: Vector2):
    current_upgrade_id = upgrade_id
    var data = PlayerResources.upgrade_data[upgrade_id]
    var cost = PlayerResources.get_upgrade_cost(upgrade_id)
    
    # Populate UI
    if data.max_level > 0:
        title_label.text = "%s (%d/%d)" % [data.name, data.level, data.max_level]
    else:
        title_label.text = "%s (Lvl %d)" % [data.name, data.level]

    desc_label.text = data.description
    icon_rect.texture = data.icon
    cost_label.text = "Cost: $%d" % cost
    
    # Button State
    buy_button.text = "Research"
    var is_maxed = (data.max_level > 0 and data.level >= data.max_level)
    
    if is_maxed:
        cost_label.text = "MAX LEVEL"
        buy_button.text = "Completed"
        buy_button.disabled = true
    elif PlayerResources.money < cost:
        buy_button.disabled = true
    elif not PlayerResources.is_upgrade_available(upgrade_id):
        buy_button.disabled = true
        cost_label.text = "Locked (Requires %s)" % data.prerequisite.name
    else:
        buy_button.disabled = false
        
    if Vector2.ZERO != position:
        position = position
        
    visible = true

func _on_buy_pressed():
    PlayerResources.purchase_upgrade(current_upgrade_id)
    open(current_upgrade_id, Vector2.ZERO) # Refresh UI (Level up, new cost)
