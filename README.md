# VR-gesture-recognition-godot
a module for gesture recognition in vr for godot
uses the $p recognizer , modified for 3d

demonstration:
https://youtu.be/tnYyMb3XGeg

this module was made with the oculus vr toolkit for godot 
https://github.com/NeoSpark314/godot_oculus_quest_toolkit

and the gesture recognition algorithm used is the $p algorithm modified for 3d
the vr_player scene, contains the p_recog_tracked object, 
this is the object which is tracked through 3d space

in idle state 
press the index trigger to start tracking
and enter recognize mode
any movement is tracked 
and once the index trigger is released tracking stops
and puts the user back into idle state
and the system attempts to recongnise the movement

there are no pre made templates
the add button , puts the user in add mode
the next tracked movement will be made into a template

the cancel button allows the user to exit add mode

the delete button deletes all templates

the source code, during development there are two nodes , 
 p_recog_tracked object dev
 and
 p_recog_tracked object game
dev allows for adding and subtracting templates and storing them into a file for further use
game only allows you to load prexisting templates saved by dev and utilize them 
