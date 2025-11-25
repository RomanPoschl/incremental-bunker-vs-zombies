extends PanelContainer

@export var node_scene: PackedScene
@export var popup_scene: PackedScene

@onready var graph_container = $ViewPort/GraphContainer
@onready var close_button = $CloseButton

var popup_instance

var is_panning: bool = false
var current_zoom: float = 1.0
const MIN_ZOOM: float = 0.5
const MAX_ZOOM: float = 2.0

const CELL_SIZE: Vector2 = Vector2(180, 140) 
const START_OFFSET: Vector2 = Vector2(50, 50)

func _ready():
    mouse_filter = Control.MOUSE_FILTER_STOP

    popup_instance = popup_scene.instantiate()
    popup_instance.visible = false
    popup_instance.top_level = true
    add_child(popup_instance)
    
    Events.upgrade_purchased.connect(func(_id, _val): queue_redraw())
    Events.tech_node_clicked.connect(_on_node_clicked)
    close_button.pressed.connect(_on_close_pressed)
    
    call_deferred("_generate_tree")

func _generate_tree():
    for child in graph_container.get_children():
        child.queue_free()
        
    for id in PlayerResources.upgrade_data:
        var data = PlayerResources.upgrade_data[id]
        var node = node_scene.instantiate() as Control
        
        var grid_pos = data.grid_position
        var pixel_pos = START_OFFSET + (Vector2(grid_pos) * CELL_SIZE)
        
        node.position = pixel_pos
        graph_container.add_child(node)
        node.setup(id)
        
    graph_container.position = size / 2

func _draw():
    pass

func _on_node_clicked(upgrade_id: String, position: Vector2):
    popup_instance.open(upgrade_id, position)

func _gui_input(event):
    if not self.visible: return
    
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_MIDDLE or event.button_index == MOUSE_BUTTON_RIGHT:
            if event.pressed:
                is_panning = true
            else:
                is_panning = false
            accept_event()
        
        if event.button_index == MOUSE_BUTTON_WHEEL_UP:
            _apply_zoom(0.1, event.position)
            accept_event()
        if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
            _apply_zoom(-0.1, event.position)
            accept_event()

    if event is InputEventMouseMotion and is_panning:
        graph_container.position += event.relative
        accept_event()

func _apply_zoom(amount: float, center_point: Vector2):
    var old_zoom = current_zoom
    current_zoom = clamp(current_zoom + amount, MIN_ZOOM, MAX_ZOOM)
    
    graph_container.scale = Vector2(current_zoom, current_zoom)
    
    var zoom_factor = current_zoom / old_zoom
    var local_mouse = (center_point - graph_container.position)
    graph_container.position -= local_mouse * (zoom_factor - 1.0)

func _on_close_pressed():
    visible = false
