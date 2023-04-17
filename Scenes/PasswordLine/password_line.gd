extends Control

@onready var password = $Password
@onready var login = $Login
@onready var header = $PasswordHeader
@export var example = false
@onready var description = $PasswordDescription
var is_editor_created = false
var header_text:
	set(value):
		header_text = value
		#await $PasswordHeader.ready
		$PasswordHeader.text = value
var password_text:
	set(value):
		password_text = value
		#await $Password.ready
		$Password.text = value
var login_text:
	set(value):
		login_text = value
		#await $Login.ready
		$Login.text = value
var description_text:
	set(value):
		description_text = value
		#await $Login.ready
		$PasswordDescription.text = value

var check_selection = false

var id = 0

var default_login_x = 67
var default_password_x = 84
var default_header_x = 111

signal password_line_deleted(id)
signal password_data_changed(id, header, login, password)

# Called when the node enters the scene tree for the first time.
func _ready():
	$EditPassword.size = Vector2i(25,25)
	$DeletePassword.size = Vector2i(25,25)
	_on_password_resized()
	_on_login_resized()
	_on_password_header_resized()
	if(!example):
		if(is_editor_created):
			_on_edit_password_pressed()
			$EditPassword.button_pressed = true
			$PasswordHeader.text="Password " + str(id+1)
			emit_signal("password_data_changed", id, header.text, login.text, password.text)
	else:
		$PasswordHeader.text = "Example password"
		$PasswordDescription.text = "This is a password's field example description"
		$Password.text = "P@ssw0rd!"
		$Password.secret = true
		$Login.text = "Login"
		$EditPassword.disabled = true
		$DeletePassword.disabled = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	size.x = get_parent().custom_minimum_size.x
	if(get_parent().custom_minimum_size.x==648):
		size.x = get_parent().get_parent().get_parent().size.x-20
	if(check_selection):
		if($Login.has_focus()==false and $Password.has_focus()==false and $EditPassword.has_focus() == false):
				if($EditPassword.button_pressed):
					_on_edit_password_pressed()
					$EditPassword.button_pressed = false
		check_selection = false
	$PasswordDescription.size.x = 607+get_parent().get_parent().get_parent().size.x-935-10


func _on_show_secret_pressed():
	if(password.secret):
		password.secret = false
		$PasswordClipboard.disabled = false
	else:
		password.secret = true
		$PasswordClipboard.disabled = true


func _on_edit_password_pressed():
	if(login.editable and password.editable):
		$ShowSecret.button_pressed = false
		$ShowSecret.disabled = false
		password.secret = true
		login.editable = false
		password.editable = false
	else:
		$ShowSecret.button_pressed = true
		$ShowSecret.disabled = true
		$PasswordClipboard.disabled = true
		password.secret = false
		login.editable = true
		password.editable = true


func _on_login_clipboard_pressed():
	if(!password.secret):
		DisplayServer.clipboard_set(login.text)
	$NativeNotification.notification_text = "Login copied to clipboard!"
	$NativeNotification.title = "Simple Password Manager"
	$NativeNotification.notification_icon = NativeNotification.ICON_INFO
	$NativeNotification.send()


func _on_password_clipboard_pressed():
	if(!password.secret):
		DisplayServer.clipboard_set(password.text)
	$NativeNotification.notification_text = "Password copied to clipboard!"
	$NativeNotification.title = "Simple Password Manager"
	$NativeNotification.notification_icon = NativeNotification.ICON_INFO
	$NativeNotification.send()




func _on_login_resized():
	if(login==null):
		return
	$LoginClipboard.position.x+=login.size.x-default_login_x
	$PasswordLabel.position.x+=login.size.x-default_login_x
	$Password.position.x+=login.size.x-default_login_x
	$ShowSecret.position.x+=login.size.x-default_login_x
	$PasswordClipboard.position.x+=login.size.x-default_login_x
	default_login_x = login.size.x


func _on_password_resized():
	if(password==null):
		return
	$ShowSecret.position.x+=password.size.x-default_password_x
	$PasswordClipboard.position.x+=password.size.x-default_password_x
	default_password_x = password.size.x


func _on_delete_password_pressed():
	$NativeConfirmationDialog.dialog_text = "Are you sure you want to delete " + $PasswordHeader.text + "?"
	$NativeConfirmationDialog.show()
	


func _on_password_header_resized():
	$EditPassword.position.x+=$PasswordHeader.size.x-default_header_x
	$DeletePassword.position.x+=$PasswordHeader.size.x-default_header_x
	$PasswordDescription.position.x+=$PasswordHeader.size.x-default_header_x
	default_header_x = $PasswordHeader.size.x


func _on_password_header_text_changed(new_text):
	if(id==-1):
		return
	emit_signal("password_data_changed", id, new_text, login.text, password.text, description.text)


func _on_login_text_changed(new_text):
	if(id==-1):
		return
	emit_signal("password_data_changed", id, header.text, new_text, password.text, description.text)


func _on_password_text_changed(new_text):
	if(id==-1):
		return
	emit_signal("password_data_changed", id, header.text, login.text, new_text, description.text)


func _on_native_confirmation_dialog_confirmed():
	emit_signal("password_line_deleted", id)
	queue_free()


func _on_edit_password_focus_exited():
	check_selection = true

func _on_password_focus_exited():
	check_selection = true
	
func _on_login_focus_exited():
	check_selection = true


func _on_password_description_text_changed(new_text):
	if(id==-1):
		return
	emit_signal("password_data_changed", id, header.text, login.text, new_text, new_text)
