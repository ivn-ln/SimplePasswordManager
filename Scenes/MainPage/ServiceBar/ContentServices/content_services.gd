extends Control

@onready var new_service_field = preload("res://Scenes/NewServiceField/new_service.tscn")
@onready var service_entry_button = preload("res://Scenes/ServiceEntryButton/sevice_entry_button.tscn")

var lines_amount = 0

var current_service_id = -1

var edited_service_id = -1

var prev_search_text

signal service_chosen(id, description, website, passwords_array, desc_visible, passwords_visible)
signal request_changes
signal submit_changes(id, description, website, passwords_array, description_visible, passwords_visible)
signal config_saved
signal deletion_success
# Called when the node enters the scene tree for the first time.
func _ready():
	var dir = DirAccess
	var config_dir = Globals.current_user_folder+"/Services/"
	var password = Globals.current_password
	dir = dir.open(config_dir)
	if(!DirAccess.dir_exists_absolute(config_dir)):
		return
	var dir_array = dir.get_directories()
	for curr_dir in dir_array:
		var config = FileAccess.open(config_dir+"/"+curr_dir+"/"+curr_dir+"_config.cfg",FileAccess.READ)
		if(config==null):
			continue
		var config_vars = config.get_var()
		#print(config_vars)
		var service_name = config_vars[0]
		var id = config_vars[1]
		var description = config_vars[2]
		var website = config_vars[3]
		var is_desc_visible = config_vars[4]
		var is_passwords_visible = config_vars[5]
		var cfg_location = config_dir+"/"+curr_dir+"/"+curr_dir+"_config.cfg"
		var cfg_folder = config_dir+"/"+curr_dir
		create_service(service_name, id, cfg_location, cfg_folder, website, description, is_desc_visible, is_passwords_visible)
		config.close()
	$NewServiceButton.position.y=$NewServiceButton.size.y*lines_amount
	get_parent().custom_minimum_size.y=(lines_amount*2)*$NewServiceButton.size.y


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_new_service_button_pressed():
	var new_service_field_instance = new_service_field.instantiate()
	new_service_field_instance.position.y = $NewServiceButton.size.y * lines_amount
	$NewServiceButton.disabled = true
	$NewServiceButton.visible = false
	new_service_field_instance.id = lines_amount
	new_service_field_instance.connect("end", Callable(self, "_on_new_service_end"))
	add_child(new_service_field_instance)
	get_parent().custom_minimum_size.y+=$NewServiceButton.size.y

func create_service(_service_name, _id, _config, _folder, _website, _description, _is_desc_visible, _is_passwords_visible):
	var new_service_button_instance = service_entry_button.instantiate()
	new_service_button_instance.service_name = _service_name
	new_service_button_instance.cfg_location = _config
	new_service_button_instance.cfg_folder = _folder
	new_service_button_instance.size = Vector2(212, 50)
	new_service_button_instance.position.y = new_service_button_instance.size.y* _id
	new_service_button_instance.id = _id
	new_service_button_instance.website = _website
	new_service_button_instance.description = _description
	new_service_button_instance.desc_visible = _is_desc_visible
	new_service_button_instance.passwords_visible = _is_passwords_visible
	new_service_button_instance.password_cfg_location = Globals.current_user_folder+"/services/"+_service_name+"/"+_service_name+"_passwords.cfg"
	add_child(new_service_button_instance)
	lines_amount+=1

func _on_new_service_end(success, id):
	$NewServiceButton.disabled = false
	$NewServiceButton.visible = true
	if(id!=-1):
		$NewServiceButton.position.y-=31
		var services_array = get_children()
		for service in services_array:
			if(service.name.contains("SeviceEntryButton")):
				service.disabled = false
				if(id<service.id):
					pass
					service.position.y-=31
				elif(id==service.id):
					#service._on_pressed()
					service.visible = true
	if(success):
		lines_amount+=1
		$NewServiceButton.position.y+=$NewServiceButton.size.y
	else:
		if(id!=-1):
			var services_array = get_children()
			for service in services_array:
				if(service.name.contains("SeviceEntryButton")):
					if(id==service.id):
						service.visible = true
		get_parent().custom_minimum_size.y-=$NewServiceButton.size.y

func _on_service_chosen(id, service_name, description, website, passwords_array, desc_visible, passwords_visible):
	if(current_service_id!=-1):
		emit_signal("request_changes")
	current_service_id = id
	emit_signal("service_chosen", id, service_name, description, website, passwords_array, desc_visible,passwords_visible)

func _on_deletion_request(id):
	_on_service_content_delete_service(id, true)
	emit_signal("deletion_success")

func _on_service_content_delete_service(id, no_shift=false):
	var services_array = get_children()
	var was_deleted = false
	for service in services_array:
		if(service.name.contains("SeviceEntryButton")):
			if(id==service.id):
				service.config_delete()
				service.queue_free()
				was_deleted = true
				break
	if(!was_deleted):
		return
	lines_amount-=1
	for service in services_array:
		if(service.name.contains("SeviceEntryButton")):
			if(id<service.id):
				print("I am service #", id)
				if(!no_shift):
					service.position.y-=$NewServiceButton.size.y 
					service.id-=1
					service.config_save()
		elif(service.name!="Background"):
			service.position.y-=$NewServiceButton.size.y
	emit_signal("service_chosen", -1, "ExampleService", "description", "website", [], true, true)
	

func _on_config_saved():
	emit_signal("config_saved")

func _on_service_content_submit_changes(id, description, password_array, website, description_visible, passwords_visible):
	emit_signal("submit_changes", id, description, website, password_array, description_visible, passwords_visible)


func _on_service_content_edit_service(id):
	var services_array = get_children()
	edited_service_id = id
	emit_signal("service_chosen", -1, "ExampleService", "description", "website", [], true, true)
	$NewServiceButton.disabled = true
	for service in services_array:
		if(service.name.contains("SeviceEntryButton")):
			service.disabled = true
			if(id==service.id):
				service.visible = false
				$NewServiceButton.position.y+=31
				var new_service_field_instance = new_service_field.instantiate()
				new_service_field_instance.position.y = $NewServiceButton.size.y * id
				new_service_field_instance.id = id
				new_service_field_instance.start_service_name = service.service_name
				new_service_field_instance.connect("end", Callable(self, "_on_new_service_end"))
				add_child(new_service_field_instance)
				new_service_field_instance
			if(id<service.id):
				service.position.y+=31


func _on_service_bar_search(_search_text):
	var services_array = get_children()
	var a = ""
	if(prev_search_text!=null):
		for service in services_array:
			if(service.name.contains("SeviceEntryButton")):
				if(!service.service_name.to_lower().contains(prev_search_text.to_lower())):
					$NewServiceButton.position.y+=50
					service.visible = true
					var service_not_found_id = service.id
					for _service in services_array:
						if(_service.name.contains("SeviceEntryButton")):
							if(_service.id > service_not_found_id):
								_service.position.y+=50
	prev_search_text = _search_text
	for service in services_array:
		if(service.name.contains("SeviceEntryButton")):
			if(!service.service_name.to_lower().contains(_search_text.to_lower())):
				$NewServiceButton.position.y-=50
				service.visible = false
				var service_not_found_id = service.id
				for _service in services_array:
					if(_service.name.contains("SeviceEntryButton")):
						if(_service.id > service_not_found_id):
							_service.position.y-=50
			else:
				service.visible = true
	if(_search_text == ""):
		for service in services_array:
			if(service.name.contains("SeviceEntryButton")):
				service.visible = true
				service.position.y = service.id*50
				$NewServiceButton.position.y+=50
				prev_search_text = null
