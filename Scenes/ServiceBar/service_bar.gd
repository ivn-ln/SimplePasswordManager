extends Button

var search_text = ""

signal search(_search_text)
signal search_start
signal search_end
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_search_button_pressed():
	$LineEdit.visible = true
	$LineEdit.editable = true
	$SearchButton.visible = false
	$Label.visible = false
	$LineEdit.grab_focus()
	emit_signal("search_start")


func _on_line_edit_text_changed(new_text):
	search_text = new_text
	emit_signal("search" ,new_text)


func _on_button_pressed():
	$LineEdit.visible = false
	$LineEdit.editable = false
	$SearchButton.visible = true
	$Label.visible = true
	$LineEdit.text = ""
	emit_signal("search_end")
	emit_signal("search" , "")
