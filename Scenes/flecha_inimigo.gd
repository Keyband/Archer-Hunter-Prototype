extends RigidBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var dano = 1
onready var corpo_da_flecha = get_node('corpo da flecha')
onready var ponta_da_flecha = get_node('Area2D/ponta da flecha')


func _ready():
	self.add_to_group('projetil')
	add_collision_exception_with(self)
	set_physics_process(true)
	pass

func _physics_process(delta):
	var direcao = self.get_linear_velocity().normalized()
	set_rotation(direcao.angle())
	pass

func _on_Area2D_body_entered( body ):
	if body.is_in_group('player') and self.get_mode() != 1:
		body._causar_dano(dano)
		self.queue_free()
	elif body is StaticBody2D or body.is_in_group('projetil'):
		self.set_mode(MODE_STATIC)
		get_node('Timer').start()
	pass


func _on_Timer_timeout():
	queue_free()
	pass # replace with function body
