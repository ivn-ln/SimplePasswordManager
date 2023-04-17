extends Button

var id = 1

var description = ""

var website = ""

var cfg_location = ""

var cfg_folder = ""

var password_cfg_location = ""

var passwords_array = []

var desc_visible = true

var passwords_visible = true

var is_editor_created = false
@export var service_name:String :
	set(value):
		#await self.tree_entered
		service_name = value
		$Label.text = service_name
		tooltip_text = service_name

@export var service_icon:Texture2D :
	set(value):
		#await self.tree_entered
		service_icon = value
		$TextureRect.texture = service_icon

signal chosen(id, service_name, description, website, passwords_array, desc_visible, passwords_visible)
signal request_changes(id)
signal config_saved
# Called when the node enters the scene tree for the first time.
func _ready():
	connect("chosen", Callable(get_parent(), "_on_service_chosen"))
	if(is_editor_created):
		emit_signal("chosen", id, service_name, description, website, passwords_array, desc_visible, passwords_visible)
	get_parent().connect("submit_changes", Callable(self, "_on_submit_changes"))
	connect("config_saved", Callable(get_parent(), "_on_config_saved"))
	if(FileAccess.file_exists(password_cfg_location)):
		passwords_array = FileAccess.open(password_cfg_location, FileAccess.READ).get_var()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func config_save():
	var service_config = FileAccess
	service_config = service_config.open("res://services/"+service_name+"/"+service_name+"_config.cfg", FileAccess.WRITE)
	var storable_vars = [service_name, id, description, website, desc_visible, passwords_visible]
	service_config.store_var(storable_vars)
	service_config.close()
	var password_config = FileAccess
	password_config = password_config.open("res://services/"+service_name+"/"+service_name+"_passwords.cfg", FileAccess.WRITE)
	password_config.store_var(passwords_array)

func config_delete():
	DirAccess.remove_absolute(cfg_location)
	DirAccess.remove_absolute(password_cfg_location)
	DirAccess.remove_absolute(cfg_folder)
	

func _on_submit_changes(_id, _description, _website, _passwords_array, _desc_visible, _passwords_visible):
	if(_id!=id):
		return
	if(_description!=null):
		description = _description
	if(_website!=null):
		website = _website
	if(_passwords_array)!=null:
		passwords_array = _passwords_array
	if(_desc_visible!=null):
		desc_visible = _desc_visible
	if(passwords_visible!=null):
		passwords_visible = _passwords_visible
	config_save()
	emit_signal("config_saved")

func _on_pressed():
	emit_signal("chosen",id, service_name, description, website, passwords_array, desc_visible, passwords_visible)
