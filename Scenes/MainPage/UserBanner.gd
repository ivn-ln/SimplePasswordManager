extends Button

enum{
	IDLE,
	HOVER,
	PRESSED,
	RESET
}

var current_animation

@export var animation_speed = 1.0

@onready var hover_pull_length = position.y+20
@onready var reverse_pull_length = position.y

# Called when the node enters the scene tree for the first time.
func _ready():
	$UserHead.color = Globals.current_color
	$UserBody.color = Globals.current_color
	$UserBody2.color = Globals.current_color
	$"../User/UserHead".color = Globals.current_color
	$"../User/UserBody".color = Globals.current_color
	$"../User/Label".text = Globals.current_user
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_mouse_entered():
	if(button_pressed):
		return
	current_animation = HOVER


func _on_mouse_exited():
	if(button_pressed):
		return
	current_animation = RESET


func _on_pressed():
	if(!button_pressed):
		current_animation = RESET
		$"../AnimationPlayer".current_animation = "Blur_in"
		return
	$"../AnimationPlayer".current_animation = "Blur_out"

func _on_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/Auth/auth_scene.tscn")


func _on_button_3_pressed():
	button_pressed = false
	current_animation = RESET
	$"../AnimationPlayer".current_animation = "Blur_in"


func _on_button_2_pressed():
	get_tree().change_scene_to_file("res://Scenes/Settings/settings_page.tscn")


func _on_native_confirmation_dialog_confirmed():
	var user_config = OS.get_user_data_dir() + "/" + Globals.current_user + "/user.cfg"
	var user_dir = OS.get_user_data_dir() + "/" + Globals.current_user
	if(FileAccess.file_exists(user_config)):
		var access_password = Globals.current_password.sha256_text()
		var user_file_stream = FileAccess.open_encrypted_with_pass(user_config, FileAccess.READ, Globals.password_phrase)
		var user_vars = user_file_stream.get_var()
		user_file_stream.close()
		if(user_vars[0]==Globals.current_user and user_vars[2]==access_password):

			OS.move_to_trash(user_dir)
		else:
			print("Error, invalid user information")
			return
		get_tree().change_scene_to_file("res://Scenes/Auth/auth_scene.tscn")
	else:
		print("Error, could not find user data")




func _on_service_bar_search_end():
	visible = true


func _on_service_bar_search_start():
	visible = false


