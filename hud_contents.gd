extends Label

@onready var label: Label = $"."
@onready var spd
func _ready():
	pass

func _process(_delta):
	label.text = "Time: " + str(spd) + " s"
	



func _on_player_get_speed(speed: Variant) -> void:
	spd = speed
