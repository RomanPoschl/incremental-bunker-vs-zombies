extends TileMapLayer

const TILE_SOURCE_ID: int = 0
const TILE_DIRT: Vector2i = Vector2i(0, 13)        # Dark ground
const TILE_BACK_WALL: Vector2i = Vector2i(0, 14)        # Dark ground
const TILE_WALL_LEFT: Vector2i = Vector2i(0, 12) # Concrete wall
const TILE_FLOOR: Vector2i = Vector2i(0, 11) # Floor pattern

const ALT_ID_FLIPPED_RIGHT: int = 1

func _ready() -> void:
    Events.level_purchased.connect(_on_level_purchased)
    
    _draw_surface()
    _draw_level(-1)
    
func _on_level_purchased(new_camera_y: float):
    var level = PlayerResources.current_max_level # e.g., -2
    _draw_level(level)
    
func _draw_surface():
    var start_x = local_to_map(Vector2(-1000, 0)).x
    var end_x = local_to_map(Vector2(1000, 0)).x
    var surface_y = local_to_map(Vector2(0, PlayerResources.SURFACE_GROUND_Y)).y
    
    for x in range(start_x, end_x):
        # Draw 5 layers of dirt
        for y in range(surface_y, surface_y + 5):
            set_cell(Vector2i(x, y), TILE_SOURCE_ID, TILE_DIRT)
            
func _draw_level(level: int):
    var depth_index = abs(level) - 1
    var floor_pixel_y = PlayerResources.LEVEL_BASE_Y + (depth_index * PlayerResources.LEVEL_HEIGHT)
    
    var left_pixel_x = PlayerResources.PLOT_START_X - 50.0
    var right_pixel_x = PlayerResources.BUNKER_ENTRANCE_X + 50.0
    
    var floor_y = local_to_map(Vector2(0, floor_pixel_y)).y
    var ceiling_y = local_to_map(Vector2(0, floor_pixel_y - PlayerResources.LEVEL_HEIGHT)).y + 2 # +2 to leave some dirt roof
    
    var start_x = local_to_map(Vector2(left_pixel_x, 0)).x
    var end_x = local_to_map(Vector2(right_pixel_x, 0)).x
    
    for x in range(start_x, end_x + 1):
        for y in range(ceiling_y, floor_y + 1):
            
            if y == floor_y:
                set_cell(Vector2i(x, y), TILE_SOURCE_ID, TILE_FLOOR)
                
            elif x == start_x:
                set_cell(Vector2i(x, y), TILE_SOURCE_ID, TILE_WALL_LEFT)
                
            elif x == end_x:
                set_cell(Vector2i(x, y), TILE_SOURCE_ID, TILE_WALL_LEFT, ALT_ID_FLIPPED_RIGHT)
                
            else:
                set_cell(Vector2i(x, y), TILE_SOURCE_ID, TILE_BACK_WALL)
