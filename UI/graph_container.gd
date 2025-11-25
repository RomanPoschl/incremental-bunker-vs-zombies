extends Control

# Spacing between grid points
const GRID_SPACING: Vector2 = Vector2(150, 120)
const CELL_SIZE: Vector2 = Vector2(180, 140)
const START_OFFSET: Vector2 = Vector2(50, 50)
const BUTTON_CENTER_OFFSET: Vector2 = Vector2(32, 32)

func _process(delta):
    queue_redraw()

func _draw():
    for id in PlayerResources.upgrade_data:
        var data = PlayerResources.upgrade_data[id]
        
        if data.prerequisite:
            var start_grid = data.prerequisite.grid_position
            var end_grid = data.grid_position
            
            var start_pos = START_OFFSET + (Vector2(start_grid) * CELL_SIZE) + BUTTON_CENTER_OFFSET
            var end_pos = START_OFFSET + (Vector2(end_grid) * CELL_SIZE) + BUTTON_CENTER_OFFSET
            
            var color = Color.GRAY
            if PlayerResources.is_upgrade_available(id):
                color = Color.WHITE
            if data.is_unlocked:
                color = Color.GREEN
                
            draw_line(start_pos, end_pos, color, 4.0)
