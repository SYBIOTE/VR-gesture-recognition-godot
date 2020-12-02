extends Spatial


onready var keyboard=$OQ_ARVROrigin/OQ_UI2DKeyboard
func _ready():
	keyboard.visible=false

func _on_Q_recog_tracked2_add_pressed():
	keyboard.visible=true


func _on_OQ_UI2DKeyboard_text_input_cancel():
	pass # Replace with function body.


func _on_OQ_UI2DKeyboard_text_input_enter():
	pass # Replace with function body.
