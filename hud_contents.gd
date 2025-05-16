extends Label

@onready var label: Label = $"."
func _ready():
	$"....".getSpeed.connect()

func _process(_delta):
	label.text = "Speed: " + str() + " m/s"
