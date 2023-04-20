extends Control

@onready var user_label = $Tabs/Account/Label

@onready var user_body = $Tabs/Account/Label/UserImage/PFPBody

@onready var user_head = $Tabs/Account/Label/UserImage/PFPHead

@onready var settings_file_path = Globals.current_user_folder + "/settings.cfg"

@onready var option_dark_theme = $Tabs/General/OptionDarkTheme

@onready var option_color_theme = $Tabs/General/OptionColorTheme

@onready var color_picker = $Tabs/General/ColorPicker

@onready var option_autoresize = $Tabs/General/OptionButton

@onready var bg = $Background

@onready var tab_bg = $TabBackground

@onready var auth_window = $Tabs/Account/Window

@onready var user_color_picker=  $Tabs/Account/ChangeColorButton/ColorPickerUser

var is_authorized = false

var request_color_change = false

var request_password_change = false

# Called when the node enters the scene tree for the first time.
func _ready():
	user_color_picker.position = Vector2i(244, -16)
	option_color_theme.disabled = false
	$Tabs/General/ColorPicker.position = Vector2i(180,0)
	if(Globals.dark_theme):
		tab_bg.visible = true
		bg.visible = true
		option_dark_theme.switch.button_pressed = true
	else:
		bg.visible = false
		tab_bg.visible = false
	if(!Globals.main_color==Color.WHITE):
		option_color_theme.switch.button_pressed =true
		color_picker.color = Globals.main_color
	option_autoresize.switch.button_pressed = Globals.autoresize
	tab_bg.self_modulate = Globals.main_color
	bg.self_modulate = Globals.main_color
	user_label.text = "You're currently logged in as " + Globals.current_user
	user_body.self_modulate = Globals.current_color
	user_head.self_modulate = Globals.current_color


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_pressed():
	var user_config = OS.get_user_data_dir() + "/" + Globals.current_user + "/user.cfg"
	if(FileAccess.file_exists(user_config)):
		var stored_vars = [Globals.current_user, Globals.current_color, Globals.current_password.sha256_text()]
		var user_config_stream = FileAccess.open_encrypted_with_pass(user_config, FileAccess.WRITE, Globals.password_phrase)
		user_config_stream.store_var(stored_vars)
		user_config_stream.close()
	if(!FileAccess.file_exists(settings_file_path)):
		var settings_config = FileAccess.open(settings_file_path, FileAccess.WRITE)
		settings_config.close()
	var settings_config = FileAccess.open(settings_file_path, FileAccess.WRITE)
	var store_array = [Globals.dark_theme ,Globals.main_color, Globals.autoresize]
	settings_config.store_var(store_array)
	settings_config.close()
	get_tree().change_scene_to_file("res://Scenes/MainPage/MainPage.tscn")


func _on_dark_theme_button_toggled(button_pressed):
	if(button_pressed):
		Globals.dark_theme = true
	else:
		Globals.dark_theme = false
	if(Globals.dark_theme):
		tab_bg.visible = true
		bg.visible = true
	else:
		bg.visible = false
		tab_bg.visible = false


func _on_color_theme_button_toggled(button_pressed):
	if(button_pressed):
		color_picker.visible = true
		Globals.move_nodes($Tabs/General/OptionColorTheme, 25, $Tabs/General)
	else:
		color_picker.visible = false
		Globals.move_nodes($Tabs/General/OptionColorTheme, -25, $Tabs/General)
		RenderingServer.set_default_clear_color(Color.DIM_GRAY)
		Globals.main_color = Color.WHITE
		bg.self_modulate = Color.WHITE
		tab_bg.self_modulate = Color.WHITE
		color_picker.color = Color.WHITE


func _on_color_picker_color_changed(color):
	##if(Globals.dark_theme):
	#	color.s = min(color.s, 0.5)
	Globals.main_color = color
	bg.self_modulate = color
	tab_bg.self_modulate = color
	RenderingServer.set_default_clear_color(color)


func _on_delete_account_button_pressed():
	$NativeConfirmationDialog.dialog_text = "Are you sure you want to delete account " + Globals.current_user +"?"
	$NativeConfirmationDialog.show()


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

func _on_optin_autoresize_button_toggled(button_pressed):
	Globals.autoresize = button_pressed


func _on_change_color_button_pressed():
	if(!is_authorized):
		auth_window.show()
		request_color_change =true
		return
	user_color_picker.visible = true


func _on_change_password_button_2_pressed():
	if(!is_authorized):
		auth_window.show()
		request_password_change = true
		return
	$Tabs/Account/ChangePasswordButton2/LineEdit.visible = true


func _on_color_picker_user_color_changed(color):
	Globals.current_color = color
	user_body.self_modulate = color
	user_head.self_modulate = color


func _on_auth_sub_user_authorized():
	is_authorized = true
	if(request_color_change):
		request_color_change = false
		user_color_picker.visible = true
	if(request_password_change):
		request_password_change = false
		$Tabs/Account/ChangePasswordButton2/LineEdit.visible = true


func _on_window_close_requested():
	$Tabs/Account/Window.hide()


func _on_change_visibility_button_pressed():
	if($Tabs/Account/ChangePasswordButton2/LineEdit.secret == false):
		$Tabs/Account/ChangePasswordButton2/LineEdit.secret = true
	else:
		$Tabs/Account/ChangePasswordButton2/LineEdit.secret = false


func _on_change_visibility_button_focus_exited():
	$Tabs/Account/ChangePasswordButton2/LineEdit.secret = true
	$Tabs/Account/ChangePasswordButton2/LineEdit/ChangeVisibilityButton.button_pressed = false


func _on_change_password_confirm_pressed():
	$Tabs/Account/ChangePasswordButton2/LineEdit.visible = false
	Globals.current_password = $Tabs/Account/ChangePasswordButton2/LineEdit.text


func _on_line_edit_text_submitted(new_text):
	_on_change_password_confirm_pressed()


func _on_line_edit_text_changed(new_text):
	if(new_text!=""):
		$Tabs/Account/ChangePasswordButton2/LineEdit/Button.disabled = false
	else:
		$Tabs/Account/ChangePasswordButton2/LineEdit/Button.disabled = true
