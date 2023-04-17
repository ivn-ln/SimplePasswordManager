extends Label

@onready var switch = $CheckButton

@onready var disabled = false:
	set(value):
		disabled = value
		if(disabled):
			$CheckButton.disabled = true
			add_theme_color_override("font_color", Color.DIM_GRAY)
		else:
			$CheckButton.disabled = false
			add_theme_color_override("font_color", Color.WHITE)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_dark_theme_button_toggled(button_pressed):
	pass # Replace with function body.
