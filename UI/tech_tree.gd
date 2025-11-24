extends PanelContainer

@export var node_scene: PackedScene
@export var popup_scene: PackedScene

@onready var graph_container = $ViewPort/GraphContainer # A Control node for spacing
var popup_instance

var is_panning: bool = false
var current_zoom: float = 1.0
const MIN_ZOOM: float = 0.5
const MAX_ZOOM: float = 2.0

func _ready():
    mouse_filter = Control.MOUSE_FILTER_STOP

    # Create the popup once
    popup_instance = popup_scene.instantiate()
    popup_instance.visible = false
    add_child(popup_instance) # Add on top of tree
    
    Events.upgrade_purchased.connect(func(_id, _val): queue_redraw())
    Events.tech_node_clicked.connect(_on_node_clicked)
    
    # Defer generation to ensure data is ready
    call_deferred("_generate_tree")

func _generate_tree():
    # Clear old
    for child in graph_container.get_children():
        child.queue_free()
        
    # Spawn Nodes
    for id in PlayerResources.upgrade_data:
        var data = PlayerResources.upgrade_data[id]
        var node = node_scene.instantiate()
        
        # Position (Arbitrary scale factor 150px)
        node.position = data.grid_position * 150.0 
        
        graph_container.add_child(node)
        node.setup(id)
        
    graph_container.position = size / 2

func _draw():
    # (Optional) Draw lines between nodes here using grid_position logic
    pass

func _on_node_clicked(upgrade_id: String):
    popup_instance.open(upgrade_id)

func _gui_input(event):
    # --- PANNING (Middle Mouse or Right Mouse) ---
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_MIDDLE or event.button_index == MOUSE_BUTTON_RIGHT:
            if event.pressed:
                is_panning = true
            else:
                is_panning = false
        
        # --- ZOOMING (Mouse Wheel) ---
        if event.button_index == MOUSE_BUTTON_WHEEL_UP:
            _apply_zoom(0.1, event.position)
        if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
            _apply_zoom(-0.1, event.position)

    # --- DRAG MOVEMENT ---
    if event is InputEventMouseMotion and is_panning:
        graph_container.position += event.relative

func _apply_zoom(amount: float, center_point: Vector2):
    var old_zoom = current_zoom
    current_zoom = clamp(current_zoom + amount, MIN_ZOOM, MAX_ZOOM)
    
    # Zoom scaling
    graph_container.scale = Vector2(current_zoom, current_zoom)
    
    # Logic to zoom towards the mouse cursor (Optional polish)
    # For simple zoom, just scaling is enough, but this keeps mouse focused:
    var zoom_factor = current_zoom / old_zoom
    var local_mouse = (center_point - graph_container.position)
    graph_container.position -= local_mouse * (zoom_factor - 1.0)
