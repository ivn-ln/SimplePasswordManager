extends Control

signal user_authorized

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_change_visibility_button_pressed():
	$Password.secret = false


func _on_change_visibility_button_focus_exited():
	$Password.secret = true


func _on_button_pressed():
	if($Password.text == Globals.current_password):
		emit_signal("user_authorized")
		$Label.visible = true
		$Label2.visible = false
	else:
		$Password.text = ""
		$Label2.visible = true
		$Label.visible = false
	$AnimationPlayer.current_animation = "show_result"

func close():
	get_parent().hide()

func _on_password_text_changed(new_text):
	if(new_text!=""):
		$Button.disabled = false
	else:
		$Button.disabled = true


func _on_window_about_to_popup():
	$Password.grab_focus()


func _on_password_text_submitted(new_text):
	_on_button_pressed()
