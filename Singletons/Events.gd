extends Node

signal request_build_menu(plot_id: int)
signal factory_builded(id: int)

signal open_upgrade_window(type: String)

signal level_purchased(new_camera_y_pos)

signal upgrade_purchased(upgrade_id, new_value)

signal tech_node_clicked(upgrade_id: String, position: Vector2)
