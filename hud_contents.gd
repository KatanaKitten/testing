extends Label

@onready var player: CharacterBody3D = $"...."

@onready var label: Label = $"."

func _process(delta: float) -> void:
	label.text = "Speed: " + str(player.speed) + " m/s"
