extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	DisplayServer.window_set_min_size(Vector2i(576, 648))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_user_banner_mouse_exited():
	pass # Replace with function body.
