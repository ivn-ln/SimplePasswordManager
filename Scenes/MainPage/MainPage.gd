extends Control

@onready var current_services_folder = Globals.current_user_folder+"/Services/"

# Called when the node enters the scene tree for the first time.
func _ready():
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
	pass


func _on_user_banner_mouse_exited():
	pass # Replace with function body.
