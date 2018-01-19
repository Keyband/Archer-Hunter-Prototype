extends KinematicBody2D

""""
Antes de tudo, uma coisa que aprendi aqui:
	velocity É RAPIDEZ COM UMA DIREÇÃO
Ou em inglês:
	VELOCITY IS SPEED WITH A DIRECTION
Resumindo, isso mata muitas duvidas na diferença entre speed e velocity.
"""

# ~~ ~~ ~~ ~~ Variáveis
var velocity = Vector2()
var numero_de_pulos = 0
var numero_de_dashes = 0
var timer_dash = 0
var direcao_movimento = 1
var flecha_preload = preload("res://Scenes/flecha.tscn")
var efeito = preload('res://Scenes/efeito_do_pulo.tscn')
var nivel_carregamento = 0
var delay_dash = 0
var timer_knockback = 0
var quantidade_knockback = 3
var direcao_knockback = -1
var animacao = ''
var estado = 'normal'
var mover_camera = false

var invencibilidade = false
var timer_da_invencibilidade_comecou = false
var piscou = true

"""
Lista de Estados e Animacoes:
	Estados:
		normal
		dash (esse eh o dodge)
		knockback
		atacando
		pulo_do_dodge
	Animacoes:
		Idle
		Walking
		Pulando
		Pulando_no_ar
		Knockback
		morte
		Caindo
		Atirando_do_chao
		Atirando_do_chaoL
		Atirando_do_ar
		Atirando_do_arL
"""
onready var raycast1 = get_node('raycast-x')
onready var raycast2 = get_node('raycast+x')
onready var barra_de_vida = get_node('Control/MarginContainer/barra de vida')
onready var barra_de_energia = get_node('Control/MarginContainer/barra de energia')
onready var sprite = get_node('Sprite')

# ~~ ~~ ~~ ~~ Constantes
const velocity_maxima = 500
const VETOR_GRAVIDADE = Vector2(0, 1750)
const VELOCIDADE_HORIZONTAL = 250 # pixels/sec
const VELOCIDADE_DO_PULO = 480
const NORMAL = Vector2(0, -1)
const MAXIMO_DE_PULOS = 2
const MAXIMO_DE_DASHES = 1

#Deletar toda essa tralha depois
onready var fps = get_node('Control/FPS')
func _atualizar_fps():
	fps.set_text(str(Engine.get_frames_per_second()))


# ~~ ~~ ~~ ~~ Funcao ready
func _ready():
	get_node('Area2D/CollisionShape2D').set_disabled(false)
	self.set_collision_layer(1)
	self.set_collision_mask(1)
	#Categorizar como um jogador
	add_to_group('player')
	#Ativar funcao process
	set_physics_process(true)
	pass

# ~~ ~~ ~~ ~~ Funcao process
#func _physics_process(delta):
func _physics_process(delta):
#	print(str(get_collision_layer()))
	get_node('CollisionShape2D').set_position(Vector2(3,5))
	if global.atingiu_o_chao:
		get_node('Camera2D').shake(0.1, 15, rand_range(5, 15))
		global.atingiu_o_chao = false
		
	
	if invencibilidade:
		_invencibilidade(delta)
	
#	if get_node('Camera2D').get_position().x == self.get_position().x and mover_camera:
#		var posicao_camera = Vector2()
#		posicao_camera.x = lerp(get_node('Camera2D').get_position().x, get_parent().get_node('enemy').get_position().x, 0.1)
##		posicao_camera.y = lerp(get_node('Camera2D').get_position().y, get_parent().get_node('enemy').get_position().y, 0.1)
#
#		if posicao_camera.x == get_parent().get_node('enemy').get_position().x:
#			mover_camera = false
#
#		get_node('Camera2D').set_position(posicao_camera)
#	elif get_node('Camera2D').get_position().x == get_parent().get_node('enemy').get_position().x and mover_camera:
#		var posicao_camera = Vector2()
#		posicao_camera.x = lerp(get_node('Camera2D').get_position().x, self.get_position().x, 0.1)
##		posicao_camera.y = lerp(get_node('Camera2D').get_position().y, get_parent().get_node('enemy').get_position().y, 0.1)
#
#		if posicao_camera.x == self.get_position().x:
#			mover_camera = false
#
#		get_node('Camera2D').set_position(posicao_camera)
#
#
#
	if direcao_movimento == 1:
		sprite.set_flip_h(false)
		get_node('flecha').set_flip_h(false)
	else:
		sprite.set_flip_h(true)
		get_node('flecha').set_flip_h(true)
		
	barra_de_energia.set_value( barra_de_energia.get_value() + 1)
	
	if estado == 'normal':
		_movimento_normal(delta)
	elif estado == 'dash':
		_dash(delta)
	elif estado == 'knockback':
		_knockback(delta, quantidade_knockback, direcao_knockback)
	elif estado == 'atacando':
		_atacando(delta, direcao_movimento)
	elif estado == 'pulo_do_dodge':
		_pulo_do_dodge(delta)
		
	if barra_de_vida.get_value() < 1:
		animacao = 'morte'
		
	if animacao != get_node('AnimationPlayer').get_current_animation():
		get_node('AnimationPlayer').play(animacao)
	_atualizar_fps()
	pass

func _invencibilidade(delta):

	if timer_da_invencibilidade_comecou == false:
		get_tree().create_timer(2.0).connect('timeout', self, '_parar_invencibilidade')
		get_node('Area2D/CollisionShape2D').set_disabled(true)
		timer_da_invencibilidade_comecou = true
		self.set_collision_layer(2)
		self.set_collision_mask(2)
		
#		self.set_modulate(Color(1,0,1,1))
	if piscou == true:
		piscou = false
		get_tree().create_timer(0.05).connect('timeout', self, '_piscar_na_invencibilidade')
		self.set_modulate(Color(1,1,1,0))
	pass
	
func _parar_invencibilidade():
	invencibilidade = false
	timer_da_invencibilidade_comecou = false
	get_node('Area2D/CollisionShape2D').set_disabled(false)
	self.set_collision_layer(1)
	self.set_collision_mask(1)
#	self.set_modulate(Color(1,1,1,1))
	pass

func _piscar_na_invencibilidade():
	piscou = true
	self.set_modulate(Color(1,1,1,1))
	pass

# ~~ ~~ ~~ ~~ Estado de dash (dodge)
func _dash(delta):
	animacao = 'Dodge'
	
	velocity.x = 450 * direcao_movimento
	velocity += 1.30 * delta * VETOR_GRAVIDADE
	
	if Input.is_action_just_pressed("ui_jump"):
		velocity.y = -VELOCIDADE_DO_PULO * 0.9
		numero_de_pulos += 1
		estado = 'normal'
		animacao = 'Pulando'
		get_node('Area2D/CollisionShape2D').set_disabled(false)
		_efeito_do_pulo()
	
	#Aplicar Move And Slide
	velocity = move_and_slide(velocity, NORMAL, 25)
	pass
	
# ~~ ~~ ~~ ~~ Estado de ataque
func _atacando(delta, direcao):
#	_atirar_flecha(direcao_movimento)
	if numero_de_pulos == 0:
		if direcao_movimento == 1:
			animacao = 'Atirando_do_chao'
		else:
			animacao = 'Atirando_do_chaoL'
		velocity.x = lerp(velocity.x, 0, 0.3)
	else:
		if direcao_movimento == 1:
			animacao = 'Atirando_do_ar'
		else:
			animacao = 'Atirando_do_arL'
		
	# ~~ ~~ ~~ ~~ Aplicação dos movimentos
	#Diminuicao da velocidade horizontal
	#Aplicar gravidade
	if velocity.y < 0 and Input.is_action_pressed("ui_jump"):
		velocity += 0.50 * delta * VETOR_GRAVIDADE
	else:
		velocity += 1.30 * delta * VETOR_GRAVIDADE
	
	#Aplicar Move And Slide
	velocity = move_and_slide(velocity, NORMAL, 25)
	pass


# ~~ ~~ ~~ ~~ Funcoes de ataque
func _atirar_flecha():
	var flecha = flecha_preload.instance()
	flecha.add_collision_exception_with(self)
	
	if direcao_movimento == 1:
		flecha.position = get_node('flecha').get_global_position()
	else:
		flecha.position = get_node('flechal').get_global_position()
		
	flecha.linear_velocity = Vector2(1000*direcao_movimento, 0)
#		flecha.apply_impulse(Vector2(), Vector2(666*direcao_movimento, 0))
	get_parent().add_child(flecha)
	pass

func _efeito_do_pulo():
	var efeito_do_pulo = efeito.instance()
	efeito_do_pulo.position = self.get_global_position() + Vector2(0, 5)
	efeito_do_pulo.set_scale(Vector2(3, 3))
#			efeito_do_pulo.set_position( self. get_position()) #+ Vector2(0, 10))
	get_parent().add_child(efeito_do_pulo)

# ~~ ~~ ~~ ~~ Estado normal
func _movimento_normal(delta):
	# ~~ ~~ ~~ ~~ Controle
	#Movimento horizontal
	var direcao = 0
	if Input.is_action_pressed("ui_left"):
		direcao = -1
		if numero_de_pulos == 0:
			animacao = 'Walking'
	if Input.is_action_pressed("ui_right"):
		direcao =  1
		if numero_de_pulos == 0:
			animacao = 'Walking'
	if direcao != 0:
		direcao_movimento = direcao
	
	velocity.x = lerp(velocity.x, direcao * VELOCIDADE_HORIZONTAL, 0.5)
	
	#Movimento Vertical; Pulando
	if Input.is_action_just_pressed("ui_jump") and numero_de_pulos < MAXIMO_DE_PULOS:
		velocity.y = -VELOCIDADE_DO_PULO
#		velocity.y = lerp(velocity.y, -VELOCIDADE_DO_PULO, 0.1)
		numero_de_pulos += 1
		if numero_de_pulos == 1:
			animacao = 'Pulando'
		elif numero_de_pulos == 2:
			animacao ='Pulando_no_ar'
			_efeito_do_pulo()
			
	#Dash
	if Input.is_action_just_pressed("ui_dash") and numero_de_dashes < MAXIMO_DE_DASHES and delay_dash > 7*delta and barra_de_energia.get_value() > 25:
		numero_de_dashes += 1
		barra_de_energia.set_value( get_node('Control/MarginContainer/barra de energia').get_value() - 40)
		estado = 'dash'
#		anim = 'Dodge'
	
	#Ataque
	if Input.is_action_just_pressed('ui_attack'):
		estado = 'atacando'
	
	# ~~ ~~ ~~ ~~ Aplicação dos movimentos
	#Aplicar gravidade
	if velocity.y < 0 and Input.is_action_pressed("ui_jump"):
		velocity += 0.50 * delta * VETOR_GRAVIDADE
	else:
		velocity += 1.30 * delta * VETOR_GRAVIDADE
	
	#Aplicar Move And Slide
	velocity = move_and_slide(velocity, NORMAL, 25)
	
	# ~~ ~~ ~~ ~~ Checks, incrementos, e debug
	#Esta parado?
	if velocity.x == 0 and numero_de_pulos == 0:
		animacao = 'Idle'
	
	#Esta no chao?
	if is_on_floor():
		numero_de_pulos = 0
		numero_de_dashes = 0
		
	#Incrementos de tempo
	delay_dash += delta
	
	#Debug
	if Input.is_action_just_pressed('ui_debug'):
		_causar_dano(5)
		estado = 'knockback'
		
#		mover_camera = true
		
#		if get_node('Camera2D').is_current():
#			get_parent().get_node('enemy/Camera2D')._set_current(true)
#		else:
#			get_node('Camera2D')._set_current(true)

func _causar_dano(dano):
	if barra_de_vida.get_value() > 0:
		barra_de_vida.set_value(barra_de_vida.get_value() - dano)
#		get_node('Camera2D').shake(0.2, 15, 8)
		get_node('Camera2D').shake(0.2, 15, 20)
		invencibilidade = true
	pass

func _knockback(delta, quantidade = 2, direcao = -1):
	animacao = 'Knockback'
	velocity = Vector2( 100 * direcao, 0)
	velocity = move_and_slide( velocity, NORMAL, 25)
	pass

func _on_Area2D_body_entered( body ):
	if body.is_in_group('inimigo'):
		_causar_dano(body.dano_proprio)
		direcao_knockback = sign( self.position.x - body.position.x )
		estado = 'knockback'
	pass


func _on_AnimationPlayer_animation_finished( name ):
	if name == 'Atirando_do_chao' or name == 'Atirando_do_chaoL':
		estado = 'normal'
	elif name == 'Atirando_do_ar' or name == 'Atirando_do_arL':
		estado = 'normal'
		animacao = 'Caindo'
	elif name == 'Dodge':
		estado = 'normal'
	elif name == 'Knockback':
		estado = 'normal'
		invencibilidade = true
	pass
	
