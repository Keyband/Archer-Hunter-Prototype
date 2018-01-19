extends RigidBody2D

#Variaveis
export var vida = 2
export var dano_proprio = 5
var timer = 0
var random_timer = 2
export var tempo_min = 100
export var tempo_max = 300
onready var texto = get_node('Vida')
onready var raycastl = get_node('raycastl')
onready var raycastr = get_node('raycastr')
var animacao = 'Idle'

#"Constantes"
export var IMPULSO_DO_PULO = 600

func _ready():
	set_process(true)
	add_to_group('inimigo')
	texto.set_text(str(vida))
	pass

func _process(delta):
	var no_chao = raycastl.is_colliding() or raycastr.is_colliding() or get_linear_velocity().y == 0
		
	if no_chao:
		animacao = 'Idle'
	else:
		animacao = 'Pulando'
	if timer > random_timer*delta and no_chao:
		randomize()
		timer = 0
		random_timer = rand_range(tempo_min,tempo_max)
		
		var angulo = rand_range(35, 145)
		var impulso = IMPULSO_DO_PULO * Vector2(cos(angulo), - sin(angulo))
		apply_impulse(Vector2(), impulso)
	else:
		timer += delta

	#Aplicar gravidade
	if get_linear_velocity().y < 0:
		gravity_scale = 0.5
	else:
		gravity_scale = 1
	
	if animacao != get_node('AnimationPlayer').get_current_animation():
		get_node('AnimationPlayer').play(animacao)
#
##	#Aplicar Move And Slide
##	velocity = move_and_slide(velocity, NORMAL, 25)
#	set_linear_velocity(velocity)

func _causar_dano(dano):
	if vida > 0:
		vida -= dano
		texto.set_text(str(vida))
	else:
		queue_free()
	pass
