extends Camera2D

@export_group("Speed")
@export var move_speed: float = 500.0
@export var zoom_speed: float = 0.1
@export var drag_speed: float = 1.0

@export_group("Limits")
@export var min_zoom: float = 0.5
@export var max_zoom: float = 3.0
@export var limit_rect: Rect2

var is_dragging: bool = false
var is_pinching: bool = false
var touch_points = {}
var prev_pinch_distance: float = 0.0

func _ready():
    set_process_input(true)
    Events.level_purchased.connect(_on_level_purchased)

func _process(delta: float):
    var move_vector := Vector2.ZERO

    move_vector = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

    if move_vector != Vector2.ZERO:
        position += move_vector * move_speed * (1.0 / zoom.x) * delta

    if limit_rect != Rect2(0,0,0,0):
        position.x = clamp(position.x, limit_rect.position.x, limit_rect.end.x)
        position.y = clamp(position.y, limit_rect.position.y, limit_rect.end.y)

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_WHEEL_UP:
            _apply_zoom(1.0 + zoom_speed)
        elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
            _apply_zoom(1.0 - zoom_speed)

        if event.button_index == MOUSE_BUTTON_MIDDLE:
            is_dragging = event.pressed

    if event is InputEventMouseMotion and is_dragging:
        position -= event.relative * drag_speed * (1.0 / zoom.x)

    if event is InputEventScreenTouch:
        if event.pressed:
            touch_points[event.index] = event.position
        else:
            if touch_points.has(event.index):
                touch_points.erase(event.index)

            is_pinching = false
            prev_pinch_distance = 0.0

    if event is InputEventScreenDrag:
        if not touch_points.has(event.index):
            return

        touch_points[event.index] = event.position

        if touch_points.size() == 2:
            is_pinching = true

            var points = touch_points.values()
            var p1 = points[0]
            var p2 = points[1]

            var current_pinch_distance = p1.distance_to(p2)

            if prev_pinch_distance > 0:
                var zoom_delta = current_pinch_distance / prev_pinch_distance
                _apply_zoom(zoom_delta)

            prev_pinch_distance = current_pinch_distance

        elif touch_points.size() == 1 and not is_pinching:
            position -= event.relative * drag_speed * (1.0 / zoom.x)

func _apply_zoom(amount: float):
    zoom *= amount
    zoom.x = clamp(zoom.x, min_zoom, max_zoom)
    zoom.y = clamp(zoom.y, min_zoom, max_zoom)

func _on_level_purchased(new_camera_y: float):
    var tween = create_tween()
    tween.set_trans(Tween.TRANS_SINE)
    
    tween.tween_property(self, "position:y", new_camera_y, 1.0)
