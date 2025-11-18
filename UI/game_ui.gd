extends CanvasLayer

@onready var container = $VBoxContainer
var money_label: Label
var ammo_labels: Dictionary = {}

var buy_level_button: Button
var player_input_node

var active_plot_id: int = -1

func _ready() -> void:
    var label = Label.new()
    label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    container.add_child(label)
    money_label = label
    
    buy_level_button = Button.new()
    container.add_child(buy_level_button)
    buy_level_button.pressed.connect(_on_buy_level_pressed)
    
    Events.request_build_menu.connect(_on_build_menu_requested)

func _process(delta: float) -> void:
    money_label.text = "%s: %s" % ["MONEY", PlayerResources.money]
    
    var cost = PlayerResources.next_level_cost
    var next_level = PlayerResources.current_max_level + 1
    buy_level_button.text = "Buy Level %s ($%s)" % [next_level, cost]
    buy_level_button.disabled = (PlayerResources.money < cost)
        
    var bank = PlayerResources.global_ammo

    for ammo_type in bank:
        var amount = bank[ammo_type]

        if not ammo_labels.has(ammo_type):
            var label = Label.new()
            label.mouse_filter = Control.MOUSE_FILTER_IGNORE
            container.add_child(label)
            ammo_labels[ammo_type] = label

        var label = ammo_labels[ammo_type]
        label.text = "%s: %s" % [ammo_type.display_name.capitalize(), amount]

func _on_buy_level_pressed():
    PlayerResources.purchase_new_level()

func _on_build_menu_requested(plot_id):
    active_plot_id = plot_id
    for child in $BuildMenu/HBoxContainer.get_children():
        child.queue_free()
        
    for factory_id in PlayerResources.factory_db:
        var factory_data: FactoryType = PlayerResources.factory_db[factory_id]
        
        var btn = Button.new()
        btn.text = "%s ($%d)" % [factory_data.display_name, factory_data.build_cost]
        btn.pressed.connect(_on_build_factory_pressed.bind(factory_data))
        
        $BuildMenu/HBoxContainer.add_child(btn)
        
    $BuildMenu.visible = true

func _on_build_factory_pressed(data: FactoryType):
    if PlayerResources.spend_money(data.build_cost):
        EcsWorld.build_factory_at_plot(active_plot_id, data)
        active_plot_id = 0
        $BuildMenu.visible = false
