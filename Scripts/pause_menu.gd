extends Control

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	set_process(true)
	pass

func _process(delta):
	if Input.is_action_just_pressed('ui_pause'):
		if not get_tree().is_paused():
			get_tree().set_pause(true)
			self.visible = true
		else:
			get_tree().set_pause(false)
			self.visible = false
	pass
