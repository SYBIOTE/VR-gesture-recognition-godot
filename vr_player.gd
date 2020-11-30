extends Spatial

onready var tracked_obj=$OQ_ARVROrigin/OQ_RightController/Q_recog_tracked

func _on_delete_pressed():
	$OQ_ARVROrigin/OQ_LeftController/OQ_VisibilityToggle/OQ_UILabel.set_label_text("all gestures deleted")
	tracked_obj.delete_gesture()
	id_count=0

var id_count=1


func _on_add_pressed():
	tracked_obj.add_mode=true
	tracked_obj.add_name="type " + str(id_count)
	id_count+=1
	$OQ_ARVROrigin/OQ_LeftController/OQ_VisibilityToggle/OQ_UILabel.set_label_text(tracked_obj.add_name + " added")


func result(string):
	$OQ_ARVROrigin/OQ_LeftController/OQ_VisibilityToggle/OQ_UILabel.set_label_text("matched with " + string)

