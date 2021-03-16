extends Spatial
onready var ui_pos=$ui_marker_pos
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var controller : ARVRController = get_parent()
	if controller:
		var grip = controller.is_button_pressed(vr.CONTROLLER_BUTTON.GRIP_TRIGGER)*4
		var trigger = controller.is_button_pressed(vr.CONTROLLER_BUTTON.TOUCH_INDEX_TRIGGER)*7
		$AnimationTree.set("parameters/Blend2/blend_amount", trigger)
		$AnimationTree.set("parameters/SetGrip/seek_position", grip)
		$AnimationTree.set("parameters/SetIndex/seek_position", trigger)
		# print("Grip: " + str(grip) + " Trigger: " + str(trigger))
