extends Node

var factory_cost: int = 100
var plot_size: Vector2 = Vector2(32, 32)
var desk_size: Vector2 = Vector2(32, 32)
var factory_size: Vector2 = Vector2(32, 32)
var half_plot_size: Vector2
var half_desk_size: Vector2
var half_factory_size: Vector2

var plots: Dictionary
var desks: Dictionary
var productions: Dictionary
var positions: Dictionary

func _ready() -> void:
    plots = EcsWorld.plots
    desks = EcsWorld.desks
    productions = EcsWorld.productions
    positions = EcsWorld.positions

    half_plot_size = plot_size / 2.0
    half_desk_size = desk_size / 2.0
    half_factory_size = factory_size / 2.0

func _unhandled_input(event: InputEvent):
    if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        _handle_click(event.position)

func _handle_click(mouse_pos: Vector2) -> void:
    for factory_id in productions:
        if not positions.has(factory_id): continue
        
        var factory_pos = positions[factory_id].position
        var factory_rect = Rect2(factory_pos - half_factory_size, factory_size)
        
        if factory_rect.has_point(mouse_pos):
            print("Clicked on factory: ", factory_id)
            Events.open_upgrade_window.emit("factory") # Emit the category
            return
  
    for desk_id in desks:
        if not positions.has(desk_id):
            continue

        var desk_pos = positions[desk_id].position
        var desk_rect = Rect2(desk_pos - half_desk_size, desk_size)

        if desk_rect.has_point(mouse_pos):
            print("Clicked on desk: ", desk_id)
            Events.open_upgrade_window.emit("worker")
            return

    for plot_id in plots.keys():
        if not positions.has(plot_id):
            continue

        var plot_pos = positions[plot_id].position
        var plot_rect = Rect2(plot_pos - half_plot_size, plot_size)

        if plot_rect.has_point(mouse_pos):
            _try_build_on_plot(plot_id)
            return

func _try_build_on_plot(plot_id: int):
    Events.request_build_menu.emit(plot_id)
