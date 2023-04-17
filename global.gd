extends Node

const password_phrase = "u1l8X!F5WtTO5#3EyT9E@JBa"

var current_user = "Username"

var current_password = "debug1337"

var current_color = Color.WHITE

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	#print(DisplayServer.window_get_min_size())
	

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		get_tree().quit() # default behavior

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
