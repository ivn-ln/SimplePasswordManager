extends Control

var web_address = "http://godotengine.org":
	set(value):
		web_address = value
		if(web_address!=""):
			$Header/Label.self_modulate = Color.LIGHT_SKY_BLUE
			$Header.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			$Header.disabled = false
		else:
			$Header/Label.self_modulate = Color.WHITE
			$Header.mouse_default_cursor_shape = 0
			$Header.disabled = true
var lines_amount = 0
var margin = 20
var is_desc_hidden = false
var is_pass_hidden = false
@onready var default_header_size = $Header.size
var password_array = []
var password_data_array = []
var current_service_id = -1:
	set(value):
		current_service_id = value
		if(current_service_id==-1):
			$ScrollContainer/PasswordContent/NewPassword.disabled = true
			$Description.text= "Choose or create a service on the left tab to get started"
			$Header/Label.text= "Simple Password Manager"
			$Header.text= "Simple Password Manager"
			web_address = "http://godotengine.org"
			var new_pass = create_new_password(-1)
			$Header/EditService.disabled = true
			$Header/DeleteService.disabled = true
			$Header/EditService.visible = false
			$Header/DeleteService.visible = false
			$Header/OpenWeb.visible = false
		else:
			$ScrollContainer/PasswordContent/NewPassword.disabled = false
			$Header/EditService.disabled =false
			$Header/DeleteService.disabled = false
			$Header/EditService.visible = true
			$Header/DeleteService.visible = true
			$Header/OpenWeb.visible = true
@onready var password_line = preload("res://Scenes/PasswordLine/password_line.tscn")

signal delete_service(id)

signal edit_service(id)

signal submit_changes(id, description, password_array, website, description_visible, passwords_visible)

# Called when the node enters the scene tree for the first time.
func _ready():
	self.current_service_id = -1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$ScrollContainer/PasswordContent.custom_minimum_size.x = (size.x)*2
	$ScrollContainer/PasswordContent.custom_minimum_size.x = min($ScrollContainer/PasswordContent.custom_minimum_size.x, 648)



func _on_header_pressed():
	if(!web_address.begins_with("http://") and !web_address.begins_with("https://")):
		print("https://"+web_address)
		print(OS.shell_open("https://"+web_address))
	else:
		OS.shell_open(web_address)


func _on_new_password_pressed():
	create_new_password(lines_amount, true)
	lines_amount+=1


func create_new_password(id, is_editor_created=false) -> Node:
	var draw_id = id
	if(id==-1):
		draw_id=0
	var password_line_instance = password_line.instantiate()
	password_line_instance.id = id
	password_line_instance.position.y = draw_id * (password_line_instance.size.y+margin)
	password_line_instance.position.x = 10
	password_line_instance.connect("password_line_deleted", Callable(self, "_on_password_line_deleted"))
	password_line_instance.connect("password_data_changed", Callable(self, "_on_password_data_changed"))
	password_line_instance.is_editor_created = is_editor_created
	if(id==-1):
		password_line_instance.example = true
	$ScrollContainer/PasswordContent.add_child(password_line_instance)
	$ScrollContainer/PasswordContent/NewPassword.position.y+=password_line_instance.size.y+margin
	$ScrollContainer/PasswordContent.custom_minimum_size.y+=password_line_instance.size.y+margin
	password_array.append(password_line_instance)
	return password_line_instance

func _on_password_data_changed(id, header, login, password, description):
	var temp_pass_data_array = []
	temp_pass_data_array.append(id)
	temp_pass_data_array.append(header)
	temp_pass_data_array.append(login)
	temp_pass_data_array.append(password)
	temp_pass_data_array.append(description)
	for i in password_data_array:
		if(i[0] == id):
			password_data_array.remove_at(password_data_array.find(i))
	password_data_array.append(temp_pass_data_array)
	save_popup()
	emit_signal("submit_changes", current_service_id, $Description.text, password_data_array, web_address, !$HideDescription.button_pressed, !$HidePasswords.button_pressed)

func _on_hide_description_pressed():
	if($Description.visible):
		$ScrollContainer.position.y-=$Description.size.y
		$HidePasswords.position.y-=$Description.size.y
		$PasswordsHeader.position.y-=$Description.size.y
		$Description.visible = false
		$ScrollContainer.size.y+=$Description.size.y
		is_desc_hidden = true
	else:
		$ScrollContainer.size.y-=$Description.size.y
		$ScrollContainer.position.y+=$Description.size.y
		$HidePasswords.position.y+=$Description.size.y
		$PasswordsHeader.position.y+=$Description.size.y
		$Description.visible = true
		is_desc_hidden = false


func _on_hide_passwords_pressed():
	if($ScrollContainer/PasswordContent.visible):
		$ScrollContainer/PasswordContent.visible = false
		is_pass_hidden = true
	else:
		$ScrollContainer/PasswordContent.visible = true
		is_pass_hidden = false

func _on_password_line_deleted(id):
	lines_amount-=1
	var all_passwords = $ScrollContainer/PasswordContent.get_children()
	all_passwords.remove_at(all_passwords.bsearch($ScrollContainer/PasswordContent/NewPassword))
	$ScrollContainer/PasswordContent/NewPassword.position.y-=70+margin
	$ScrollContainer/PasswordContent.custom_minimum_size.y-=70+margin
	for i in password_data_array:
		if(i[0]==id):
			all_passwords.remove_at(password_data_array.find(i))
	password_data_array.clear()
	#print(all_passwords)
	for pass_line in all_passwords:
		if(pass_line.id>id):
			pass_line.id-=1
			pass_line.position.y-=70+margin
		var temp_pass_data_array = [pass_line.id, pass_line.header.text, pass_line.login.text, pass_line.password.text, pass_line.description.text]
		password_data_array.append(temp_pass_data_array)
	emit_signal("submit_changes", current_service_id, $Description.text, password_data_array, web_address, !$HideDescription.button_pressed, !$HidePasswords.button_pressed)


func _on_content_services_service_chosen(id, service_name, description, website, passwords_array, desc_visible, passwords_visible):
	if(current_service_id!=-1):
		reset_header()
	if(id==current_service_id):
		return
	if($HidePasswords.button_pressed):
		_on_hide_passwords_pressed()
		$HidePasswords.button_pressed = false
	if($HideDescription.button_pressed):
		_on_hide_description_pressed()
		$HideDescription.button_pressed = false
	if(id==-1):
		clear_password()
		self.current_service_id = -1
		return
	current_service_id = id
	$Header/Label.text = service_name
	$Header.text= service_name
	$Description.text = description
	web_address = website
	$Header/WebAddress.text = website
	if(!($HideDescription.button_pressed==!desc_visible)):
		_on_hide_description_pressed()
	if(!($HidePasswords.button_pressed==!passwords_visible)):
		_on_hide_passwords_pressed()
	$HideDescription.button_pressed = !desc_visible
	$HidePasswords.button_pressed = !passwords_visible
	password_data_array = passwords_array
	
	clear_password()
	for i in passwords_array:
		var new_pass_instance = create_new_password(i[0])
		lines_amount+=1
		new_pass_instance.description_text = i[4]
		new_pass_instance.password_text = i[3]
		new_pass_instance.login_text = i[2]
		new_pass_instance.header_text = i[1]
		new_pass_instance.id = i[0]
	#emit_signal("submit_changes", current_service_id, $Description.text, password_data_array, web_address, !$HideDescription.button_pressed, !$HidePasswords.button_pressed)

func clear_password():
	lines_amount = 0
	var all_passwords = $ScrollContainer/PasswordContent.get_children()
	all_passwords.remove_at(all_passwords.bsearch($ScrollContainer/PasswordContent/NewPassword))
	$ScrollContainer/PasswordContent/NewPassword.position.y = 0
	#password_data_array.clear()
	for pass_line in all_passwords:
		pass_line.queue_free()
		$ScrollContainer/PasswordContent.custom_minimum_size.y-=70+margin


func _on_delete_service_pressed():
	$NativeConfirmationDialog.title = "Please confirm deletion"
	$NativeConfirmationDialog.dialog_text = "Are you sure you want to delete service " + $Header/Label.text + "?"
	$NativeConfirmationDialog.show()


func _on_native_confirmation_dialog_confirmed():
	clear_password()
	emit_signal("delete_service", current_service_id)



func _on_header_resized():
	if(current_service_id==-1):
		return
	#$EditService.position.x=$Header.anchor_left+$Header.size.x+10
	#$DeleteService.position.x=$Header.anchor_left+$Header.size.x+350


func _on_content_services_request_changes():
	emit_signal("submit_changes", current_service_id, $Description.text, password_data_array, web_address, !$HideDescription.button_pressed, !$HidePasswords.button_pressed)
	save_popup()

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		emit_signal("submit_changes", current_service_id, $Description.text, password_data_array, web_address, !$HideDescription.button_pressed, !$HidePasswords.button_pressed)
		save_popup()
		#await $"../../Content/ScrollContainer/ServicesBar/ContentServices".config_saved
		get_tree().quit()

func _on_content_services_config_saved():
	pass # Replace with function body.


func _on_edit_service_pressed():
	emit_signal("submit_changes", current_service_id, $Description.text, password_data_array, web_address, !$HideDescription.button_pressed, !$HidePasswords.button_pressed)
	clear_password()
	save_popup()
	emit_signal("edit_service", current_service_id)



func save_popup():
	if(current_service_id==-1):
		return
	$SavePopup/AnimationPlayer.current_animation = "RESET"
	$SavePopup/AnimationPlayer.current_animation = "fadeout_animation"





func _on_service_bar_pressed():
	emit_signal("submit_changes", current_service_id, $Description.text, password_data_array, web_address, !$HideDescription.button_pressed, !$HidePasswords.button_pressed)
	save_popup()
	_on_content_services_service_chosen(-1, "", "", "", [], true, true)


func _on_open_web_pressed():
	if($Header/OpenWeb.button_pressed):
		move_nodes($Header, $Header/WebAddress.size.y)
		$ScrollContainer.size.y-=$Header/WebAddress.size.y
		$Header/WebAddress.visible = true
	else:
		reset_header()
		
func reset_header():
	$Header/OpenWeb.button_pressed = false
	if($Header/WebAddress.visible == true):
		move_nodes($Header, -$Header/WebAddress.size.y)
		$ScrollContainer.size.y+=$Header/WebAddress.size.y
	$Header/WebAddress.visible = false
	web_address = $Header/WebAddress.text


func _on_web_address_text_changed(new_text):
	pass

func move_nodes(after: Node, amount: int) -> void:
	var should_move = false
	for node in get_children():
		if(!should_move==false):
			if "position" in node:
				node.position.y+=amount
			continue
		else:
			if(node==after):
				should_move = true

func _on_web_address_text_submitted(new_text):
	reset_header()


func _on_button_discard_pressed():
	_on_web_address_text_submitted($Header/WebAddress.text)
	


func _on_button_accept_pressed():
	$Header/WebAddress.text = ""
	reset_header()
	$Header/OpenWeb.button_pressed = false


func _on_import_from_web_pressed():
	$PickWeb.show()


func _on_pick_web_files_selected(paths):
	if(current_service_id==-1):
		return
	for cfg in paths:
		if(!cfg.ends_with('.spm')):
			print('invalid file extension')
			return
		var file_str = FileAccess.get_file_as_string(cfg)
		var name_char = file_str.find('name:')
		var login_char = file_str.find('login:')
		var password_char = file_str.find('password:')
		if(login_char!=-1 and password_char!=-1):
			var stored_name = 'Password ' + str(lines_amount)
			if(stored_name!=''):
				stored_name = file_str.substr(name_char+5, login_char-name_char-5).replace(';', '')
			var stored_login = file_str.substr(login_char+6, password_char-login_char-6).replace(';', '')
			var stored_password = file_str.substr(password_char+9).replace(';', '')
			var new_pass = create_new_password(lines_amount, true)
			new_pass.header_text = stored_name
			new_pass.login_text = stored_login
			new_pass.password_text = stored_password
			new_pass._on_password_header_text_changed(stored_name)
			lines_amount+=1
