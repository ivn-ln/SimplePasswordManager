extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



func _on_close_button_pressed():
	get_tree().quit()


func _on_maximize_button_pressed():
	if(!get_window().mode == Window.MODE_MAXIMIZED):
		get_window().mode = Window.MODE_MAXIMIZED
	else:
		get_window().mode = Window.MODE_WINDOWED


func _on_minimize_button_pressed():
	get_window().mode = Window.MODE_MINIMIZED
