extends Control

@onready var current_services_folder = Globals.current_user_folder+"/Services/"

var minmode = false

@onready var autoresize = Globals.autoresize

# Called when the node enters the scene tree for the first time.
func _ready():
	if(OS.get_name()=="Android"):
		$UserPage/Panel.visible = false
		DisplayServer.window_set_size(Vector2i(648, 1152))
	if(autoresize):
		$MinSizeButton.disabled = true
		$MinSizeButton.tooltip_text = "Disable automatical service bar hiding in settings to enable this button"
	DisplayServer.window_set_min_size(Vector2i(576, 648))
	if(!Globals.dark_theme):
		$Content/Background.visible = false
	if(!Globals.main_color==Color.WHITE):
		$Content/Background.self_modulate = Globals.main_color
		RenderingServer.set_default_clear_color(Globals.main_color)
	else:
		RenderingServer.set_default_clear_color(Color.DIM_GRAY)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(!autoresize):
		return
	if(DisplayServer.window_get_size().x<650 and !minmode):
		$MinSizeButton.button_pressed = true
	elif(minmode and DisplayServer.window_get_size().x>650):
		$MinSizeButton.button_pressed = false


func _on_user_banner_mouse_exited():
	pass # Replace with function body.


func _on_min_size_button_toggled(button_pressed):
	if(button_pressed):
		$Content/ScrollContainer.visible = false
		$Content/ServiceBar.visible = false
		$UserPage.visible = false
		$Control.position.x-=$Content/ScrollContainer.size.x
		$Control.size.x+=$Content/ScrollContainer.size.x
		$MinSizeButton.position.x-=$Content/ScrollContainer.size.x
		minmode = true
	else:
		$Content/ScrollContainer.visible = true
		$Content/ServiceBar.visible = true
		$UserPage.visible = true
		$Control.size.x-=$Content/ScrollContainer.size.x
		$Control.position.x+=$Content/ScrollContainer.size.x
		$MinSizeButton.position.x+=$Content/ScrollContainer.size.x
		minmode = false
