extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	RenderingServer.set_default_clear_color(Color.DIM_GRAY)
	DisplayServer.window_set_min_size(Vector2i(576, 648))
	$Greeting.text ="Hello, " + OS.get_environment("USERNAME") + ", please enter your login and password to proceed"
	if(FileAccess.file_exists(OS.get_user_data_dir()+"/default_settings.cfg")):
		var default_settings = FileAccess.open(OS.get_user_data_dir()+"/default_settings.cfg", FileAccess.READ)
		var default_settings_vars = default_settings.get_var()
		var should_remember = default_settings_vars[2]
		$RememberMeCheckBox.button_pressed = should_remember
		var default_color = default_settings_vars[1]
		var default_login = default_settings_vars[0]
		if(should_remember):
			$Password.grab_focus()
		$PFPBody.color = default_color
		$PFPHead.color = default_color
		$Login.text = default_login


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



func _on_password_text_changed(new_text):
	if(new_text!=""):
		$LoginButton.disabled = false
	else:
		$LoginButton.disabled = true


func _on_login_button_pressed():
	var inputed_password = $Password.text
	var inputed_login = $Login.text
	
	var config_path = OS.get_user_data_dir() + "/" + inputed_login + "/user.cfg"
	var config
	if(!FileAccess.file_exists(config_path)):
		login_reject()
		return
	config = FileAccess.open_encrypted_with_pass(config_path, FileAccess.READ, Globals.password_phrase)
	var user_data_array = config.get_var()
	var user_login = user_data_array [0]
	var user_color = user_data_array [1]
	var user_password = user_data_array [2]
	config.close()
	if(inputed_password.sha256_text()==user_password):
		check_remember_me(user_login, user_color)
		get_tree().change_scene_to_file("res://Scenes/MainPage/MainPage.tscn")
		Globals.current_user = user_login
		Globals.current_color = user_color
		Globals.current_password = inputed_password
		Globals.current_user_folder = OS.get_user_data_dir() + "/" + user_login
	else:
		password_reject()

func check_remember_me(login, color):
	var store_vars = ["", Color.WHITE, false]
	if($RememberMeCheckBox.button_pressed):
		store_vars = [login, color, true]
	var default_settings = FileAccess.open(OS.get_user_data_dir()+"/default_settings.cfg", FileAccess.WRITE)
	default_settings.store_var(store_vars)

func password_reject():
	$Password.clear()
	$Password.grab_focus()
	$AnimationPlayer.current_animation = "RESET"
	$AnimationPlayer.current_animation = "Invalid_password_animation"

func login_reject():
	$Login.clear()
	$Login.grab_focus()
	$Password.clear()
	$AnimationPlayer.current_animation = "RESET"
	$AnimationPlayer.current_animation = "Invalid_login_animation"

func _on_change_visibility_button_pressed():
	if($Password.secret):
		$Password.secret = false
	else:
		$Password.secret = true


func _on_change_color_button_pressed():
	if($ColorPicker.visible):
		$ColorPicker.visible = false
	else:
		$ColorPicker.visible = true


func _on_change_visibility_button_focus_exited():
	$Password.secret = true
	$Password/ChangeVisibilityButton.button_pressed = false


func _on_color_picker_color_changed(color):
	$PFPBody.color = color
	$PFPHead.color = color
	request_ready()
	$ResetColorButton.visible = true


func _on_change_color_button_focus_exited():
	$ColorPicker.visible = false
	$ChangeColorButton.button_pressed = false


func _on_reset_color_button_pressed():
	_on_color_picker_color_changed(Color.WHITE)
	$ResetColorButton.visible = false


func _on_create_new_account_button_pressed():
	var auth = get_tree().change_scene_to_file("res://Scenes/Registration2/registration_scene2.tscn")



func _on_password_text_submitted(new_text):
	if(!$LoginButton.disabled):
		_on_login_button_pressed()
