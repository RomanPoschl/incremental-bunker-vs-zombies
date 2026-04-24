extends Node

const SURFACE_GROUND_Y: float = 0.0
const ROW_HEIGHT: float = 5.0
const ROW_COUNT: int = 5
const LEVEL_BASE_Y: float = 96.0
const LEVEL_HEIGHT: float = 96.0
const PLOT_START_X: float = -(5.0 * 96.0) # Calculated from spacing
const PLOT_SPACING: float = 96.0
const MIN_SCALE: float = 0.75
const MAX_SCALE: float = 1.0

var current_max_level: int = -1
var next_level_cost: int = 500

func purchase_new_level():
    if PlayerResources.spend_money(next_level_cost):
        current_max_level -= 1
        next_level_cost = int(next_level_cost * 2.5)
        
        EcsWorld.spawn_new_level(current_max_level)
        
        var depth_index = abs(current_max_level) - 1
        var new_y_pos = LEVEL_BASE_Y + (depth_index * LEVEL_HEIGHT)
        
        Events.level_purchased.emit(new_y_pos)

func get_perspective_scale(y_pos: float) -> float:
    var start_y = SURFACE_GROUND_Y
    var end_y = SURFACE_GROUND_Y - (ROW_COUNT * ROW_HEIGHT)
    var t = inverse_lerp(start_y, end_y, y_pos)
    return lerp(MAX_SCALE, MIN_SCALE, clamp(t, 0.0, 1.0))

func get_perspective_modulate(y_pos: float) -> Color:
    var start_y = SURFACE_GROUND_Y
    var end_y = SURFACE_GROUND_Y - (ROW_COUNT * ROW_HEIGHT)
    var t = inverse_lerp(start_y, end_y, y_pos)
    var gray = lerp(1.0, 0.8, t)
    return Color(gray, gray, gray, 1.0)
