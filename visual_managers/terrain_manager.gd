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
    
    #for x in range(start_x, end_x):
        # Draw 5 layers of dirt
        #for y in range(surface_y, surface_y + 2):
            #set_cell(Vector2i(x, y), TILE_SOURCE_ID, TILE_DIRT)

func _draw_level(level: int):  
    var depth_index = abs(level) - 1
    var floor_pixel_y = PlayerResources.LEVEL_BASE_Y + (depth_index * PlayerResources.LEVEL_HEIGHT)
    
    # Convert Floor to Grid Y
    var floor_y = local_to_map(Vector2(0, floor_pixel_y)).y
    
    var room_height_tiles = 3 
    var ceiling_y = floor_y - (room_height_tiles - 1)
    
    var left_pixel_x = PlayerResources.PLOT_START_X - 64.0 
    var right_pixel_x = PlayerResources.BUNKER_ENTRANCE_X + 64.0
    
    var room_start_x = local_to_map(Vector2(left_pixel_x, 0)).x
    var room_end_x = local_to_map(Vector2(right_pixel_x, 0)).x
    
    var dirt_margin = 10
    for x in range(room_start_x - dirt_margin, room_end_x + dirt_margin):
        # Fill from way above ceiling to floor
        for y in range(ceiling_y - 1, floor_y + 5):
            set_cell(Vector2i(x, y), TILE_SOURCE_ID, TILE_DIRT)

    # --- STEP B: Carve the Bunker ---
    for x in range(room_start_x, room_end_x + 1):
        for y in range(ceiling_y, floor_y + 1):
            
            if y == floor_y:
                set_cell(Vector2i(x, y), TILE_SOURCE_ID, TILE_FLOOR)
            elif x == room_start_x:
                set_cell(Vector2i(x, y), TILE_SOURCE_ID, TILE_WALL_LEFT)
            elif x == room_end_x:
                set_cell(Vector2i(x, y), TILE_SOURCE_ID, TILE_WALL_LEFT, ALT_ID_FLIPPED_RIGHT)
            else:
                set_cell(Vector2i(x, y), TILE_SOURCE_ID, TILE_BACK_WALL)
