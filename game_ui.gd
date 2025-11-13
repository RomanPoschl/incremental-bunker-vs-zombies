extends CanvasLayer

@onready var container = $VBoxContainer
var ammo_labels: Dictionary = {}

func _process(delta: float) -> void:
    var bank = EcsWorld.global_ammo

    for ammo_type in bank:
        var amount = bank[ammo_type]

        if not ammo_labels.has(ammo_type):
            var label = Label.new()
            container.add_child(label)
            ammo_labels[ammo_type] = label

        var label = ammo_labels[ammo_type]
        label.text = "%s: %s" % [ammo_type.capitalize(), amount]
