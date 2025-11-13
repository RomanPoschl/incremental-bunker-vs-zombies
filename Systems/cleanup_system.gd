class_name CleanupSystem

var destroy_tags: Dictionary

func _init() -> void:
    self.destroy_tags = EcsWorld.destroy_tags


func update() -> void:
    var ids_to_destroy: Array = destroy_tags.keys()

    if ids_to_destroy.is_empty():
        return

    for entity_id in ids_to_destroy:
        EcsWorld.destroy_entity_now(entity_id)
