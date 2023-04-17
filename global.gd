extends Node

const password_phrase = "u1l8X!F5WtTO5#3EyT9E@JBa"

var current_user = "Username"

var current_password = "debug1337"

var current_user_folder = "":
	set(value):
		current_user_folder = value
		update_preferences()

var current_color = Color.WHITE

var dark_theme = false

var main_color = Color.WHITE

# Called when the node enters the scene tree for the first time.
func _ready():
	DisplayServer.window_set_min_size(Vector2i(576, 648))
	pass
	#print(DisplayServer.window_get_min_size())

func update_preferences():
	await current_user_folder!=""
	var settings_file_path = current_user_folder+"/settings.cfg"
	if(!FileAccess.file_exists(settings_file_path)):
		print("No settings for current user")
		dark_theme = false
		main_color = Color.WHITE
		return
	var settings_config = FileAccess.open(settings_file_path, FileAccess.READ)
	var settings_array = settings_config.get_var()
	settings_config.close()
	dark_theme = settings_array[0]
	main_color = settings_array[1]
	get_tree().change_scene_to_file("res://Scenes/MainPage/MainPage.tscn")

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		get_tree().quit() # default behavior

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
