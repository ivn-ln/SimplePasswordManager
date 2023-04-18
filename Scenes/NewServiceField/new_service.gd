extends Control

var service_name
var start_service_name = ""
var icon
var id

var default_service_folder = Globals.current_user_folder+"/Services/"

@onready var service_entry_button = preload("res://Scenes/ServiceEntryButton/sevice_entry_button.tscn")

signal end(success, id)
signal request_deletion(id)

# Called when the node enters the scene tree for the first time.
func _ready():
	$LineEdit.text = start_service_name
	if(start_service_name!=""):
		service_name = start_service_name
		$ConfirmButton.disabled = false
		$DiscardButton.text = "❌ "


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	#print(icon)


func _on_logo_pick_button_pressed():
	$NativeFileDialog.show()


func _on_line_edit_text_changed(new_text):
	service_name = new_text
	var service_name1 = ""
	service_name1.replace("\n", "")
	if(new_text.length()>0):
		$ConfirmButton.disabled = false
	else:
		$ConfirmButton.disabled = true


func _on_discard_button_pressed():
	if(start_service_name==""):
		id=-1
	emit_signal("end", false, id)
	queue_free()


func _on_native_file_dialog_file_selected(path):
	#print(path)
	#print(ResourceLoader.exists("res://unnamed.png"))
	icon = ResourceLoader.load(path)
	if(icon==null):
		print("Error, image is null")
		return
	$TextureRect.texture = icon
	$DiscardLogoButton.visible = true
	$DiscardLogoButton.disabled = false
	$LogoPickButton.disabled = true


func _on_discard_logo_button_pressed():
	$DiscardLogoButton.visible = false
	$DiscardLogoButton.disabled = true
	$LogoPickButton.disabled = false
	$TextureRect.texture = null


func _on_confirm_button_pressed():
	if(!DirAccess.dir_exists_absolute(default_service_folder)):
		DirAccess.make_dir_absolute(default_service_folder)
	var dir = DirAccess
	if(service_name==start_service_name):
		emit_signal("end", false, id)
		queue_free()
		return
	dir = dir.open(default_service_folder)
	if(dir.dir_exists(service_name)==true):
		_on_discard_button_pressed()
		$NativeNotification.send()
		return
	if(start_service_name!=""):
		connect("request_deletion", Callable(get_parent(), "_on_deletion_request"))
		emit_signal("request_deletion", id)
		await Callable(get_parent(), "_on_service_content_delete_service")
	dir.make_dir(service_name)
	dir.open(service_name)
	var service_config = FileAccess
	var service_config_path = default_service_folder+service_name+"/"+service_name+"_config.cfg"
	var service_config_folder =default_service_folder+service_name
	if(!DirAccess.dir_exists_absolute(service_config_folder)):
		DirAccess.make_dir_absolute(service_config_folder)
	print(service_config_path)
	service_config = service_config.open(service_config_path, FileAccess.WRITE)
	var storable_vars = [service_name, id,"", "", true, true]
	service_config.store_var(storable_vars)
	var new_service_button_instance = service_entry_button.instantiate()
	new_service_button_instance.service_name = service_name
	new_service_button_instance.id = id
	new_service_button_instance.cfg_folder = default_service_folder+service_name
	new_service_button_instance.cfg_location = service_config_path
	new_service_button_instance.password_cfg_location = default_service_folder+service_name+"/"+service_name+"_passwords.cfg"
	new_service_button_instance.is_editor_created = true
	new_service_button_instance.service_icon = icon
	#new_service_button_instance.size = size
	new_service_button_instance.position.y = position.y
	if(start_service_name==""):
		id=-1
	else:
		new_service_button_instance.position.y+=50
	get_parent().add_child(new_service_button_instance)
	emit_signal("end", true, id)
	queue_free()


func _on_line_edit_text_submitted(new_text):
	_on_confirm_button_pressed()
