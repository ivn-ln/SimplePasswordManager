extends Control

var profile_color = Color.WHITE

var from_run = false
# Called when the node enters the scene tree for the first time.
func _ready():
	DisplayServer.window_set_min_size(Vector2i(576, 648))
	$Greeting.text ="Hello, " + OS.get_environment("USERNAME") + ", please enter login and password to create local account"
	if(Globals.dark_theme):
			$Background.visible = true
	if(Globals.main_color!=Color.WHITE):
		RenderingServer.set_default_clear_color(Globals.main_color)
		$Background.self_modulate = Globals.main_color


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



func _on_password_text_changed(new_text):
	if($Password1.text!="" and $Login.text!="" and $Password.text!=""):
		$CreateAccountButton.disabled = false
	else:
		$CreateAccountButton.disabled = true


func _on_login_button_pressed():
	var inputed_password = $Password.text
	if(inputed_password == $Password1.text):
		var config_path = OS.get_user_data_dir() + "/" + $Login.text + "/user.cfg"
		var config_folder =  OS.get_user_data_dir() + "/" + $Login.text
		if(!DirAccess.dir_exists_absolute(config_folder)):
			DirAccess.make_dir_absolute(config_folder)
		if(!FileAccess.file_exists(config_path)):
			var config = FileAccess.open_encrypted_with_pass(config_path, FileAccess.WRITE, inputed_password)
			var login = $Login.text
			var password = $Password.text.sha256_text()
			var store_vars = [login, profile_color, password]
			config.store_var(store_vars)
			config.close()
		else:
			reject_login()
			return
		get_tree().change_scene_to_file("res://Scenes/Auth/auth_scene.tscn")
	else:
		reject_password()

func reject_password():
	$Password.clear()
	$Password.grab_focus()
	$AnimationPlayer.current_animation = "RESET"
	$AnimationPlayer.current_animation = "Invalid_password_animation"

func reject_login():
	$Login.clear()
	$Login.grab_focus()
	$Password.clear()
	$Password1.clear()
	$AnimationPlayer.current_animation = "RESET"
	$AnimationPlayer.current_animation = "Invalid_user_animation"

func _on_change_visibility_button_pressed():
	if($Password1.secret):
		$Password1.secret = false
	else:
		$Password1.secret = true


func _on_change_color_button_pressed():
	$ChangeColorButton/ColorPicker.position = Vector2i(80, -69)
	if($ChangeColorButton/ColorPicker.visible):
		$ChangeColorButton/ColorPicker.visible = false
	else:
		$ChangeColorButton/ColorPicker.visible = true


func _on_change_visibility_button_focus_exited():
	$Password1.secret = true
	$Password1/ChangeVisibilityButton.button_pressed = false


func _on_color_picker_color_changed(color):
	profile_color = color
	$PFPBody.color = color
	$PFPHead.color = color
	$ChangeColorButton/ResetColorButton.visible = true


func _on_change_color_button_focus_exited():
	$ChangeColorButton/ColorPicker.visible = false
	$ChangeColorButton.button_pressed = false


func _on_reset_color_button_pressed():
	_on_color_picker_color_changed(Color.WHITE)
	$ChangeColorButton/ResetColorButton.visible = false


func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/Auth/auth_scene.tscn")
