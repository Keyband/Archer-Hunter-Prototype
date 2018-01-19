extends RigidBody2D

#Variaveis
var vida = 100
export var dano_proprio = 5
var timer = 0
var random_timer = 2
var tempo_min0 = 5
var tempo_max0 = 10
var tempo_min1 = 3
var tempo_max1 = 5
var tempo_min2 = 1.5
var tempo_max2 = 4
onready var texto = get_node('Vida')
onready var raycastl = get_node('raycastl')
onready var raycastr = get_node('raycastr')
var flecha_preload = preload("res://Scenes/flecha_inimigo.tscn")
var pos_player_horizontal = -1
var vida_para_mudanca = 0.8*vida

var pode_pular = true
var no_chao = true
var estava_no_ar = false
var sinal_da_direcao = 0

var contador_para_flechas = 0

var invencibilidade = false
var timer_da_invencibilidade_comecou = false
var piscou = true

var estagio = 0
#"Constantes"
#export var IMPULSO_DO_PULO = 300000
var IMPULSO_DO_PULO = 1500
var parametro_de_flechas = 4
var contador_de_tocou_o_chao = 0
var animacao = 'Idle'


func _ready():
#	set_physics_process(true)
	set_process(true)
	add_to_group('inimigo')
	animacao = 'Idle'
	texto.set_text(str(vida))
	pass

#func _physics_process(delta):
func _process(delta):
	if get_linear_velocity() == Vector2():
		_pula_peao()
	if invencibilidade:
		_invencibilidade(delta)
		
	sinal_da_direcao = sign(pos_player_horizontal - self.get_global_position().x)
	
	#Primeiro metodo para um is_on_floor() alternativo:
	#var no_chao = raycastl.is_colliding() or raycastr.is_colliding()
	
	#Segundo metodo para um is_on_floor() alternativo:
#	no_chao = false
	if get_linear_velocity().y == 0 or raycastl.is_colliding() or raycastr.is_colliding():
		no_chao = true
		contador_de_tocou_o_chao += 1
		print("encostou")
	else:
		no_chao = false
		print('no ar')		
	if no_chao:
		if sinal_da_direcao < 0:
			get_node('Sprite').set_flip_h(false)
		else:
			get_node('Sprite').set_flip_h(true)
			
		if estava_no_ar:
			global.atingiu_o_chao = true
			estava_no_ar = false
			pode_pular = true
			animacao = 'Idle'
			if estagio == 4:
				_atirar_flechas()
			
	else:
		estava_no_ar = true
	
	if estagio == 3 or estagio == 4:
		if sinal_da_direcao < 0:
			get_node('Sprite').set_flip_h(false)
		else:
			get_node('Sprite').set_flip_h(true)
	
	if estagio == 0:
		_estagio0(delta)
	elif estagio == 1:
		_estagio1(delta)
	elif estagio == 2:
		_estagio2(delta)
	elif estagio == 3:
		_estagio3(delta)
	elif estagio == 4:
		_estagio4(delta)
	
	if animacao != get_node('AnimationPlayer').get_current_animation():
		get_node('AnimationPlayer').play(animacao)
	
func _estagio0(delta):
#	if timer > random_timer*delta and no_chao:
	if pode_pular and no_chao:
		pode_pular = false
		randomize()
#		get_tree().create_timer(rand_range(tempo_min0, tempo_max0)).connect('timeout', self, '_pode_pular')
#		get_tree().create_timer(rand_range(tempo_min0, tempo_max0)).connect('timeout', self, '_pula_peao_anim')
		get_tree().create_timer(rand_range(1, 5)).connect('timeout', self, '_pula_peao_anim')
		#		timer = 0
#		random_timer = rand_range(tempo_min0,tempo_max0)

#		var angulo = rand_range(30, 55)
#		var impulso = rand_range(550, 1050) * Vector2(cos(angulo*PI/180), - sin(angulo*PI/180)).normalized()
#		impulso.x *= sinal_da_direcao
#		apply_impulse( Vector2(), impulso)

func _estagio1(delta):
	if pode_pular and no_chao:
		pode_pular = false
		randomize()
#		get_tree().create_timer(rand_range(tempo_min1, tempo_max1)).connect('timeout', self, '_pode_pular')
		get_tree().create_timer(rand_range(0, 3)).connect('timeout', self, '_pula_peao_anim')
		#		timer = 0
#		random_timer = rand_range(tempo_min0,tempo_max0)

#		var angulo = rand_range(30, 65)
#		var impulso = rand_range(750, 1350) * Vector2(cos(angulo*PI/180), - sin(angulo*PI/180)).normalized()
#		impulso.x *= sinal_da_direcao
#		apply_impulse( Vector2(), impulso)

func _estagio2(delta):
	if pode_pular and no_chao:
		if contador_para_flechas >= 0:
			_atirar_flechas()
			contador_para_flechas = 0
		else:
			contador_para_flechas += 1
			
		pode_pular = false
		randomize()
#		get_tree().create_timer(rand_range(tempo_min2, tempo_max2)).connect('timeout', self, '_pode_pular')
		get_tree().create_timer(rand_range(0, 1.5)).connect('timeout', self, '_pula_peao_anim')
		#		timer = 0
#		random_timer = rand_range(tempo_min0,tempo_max0)

#		var angulo = rand_range(30, 65)
#		var impulso = rand_range(550, 1350) * Vector2(cos(angulo*PI/180), - sin(angulo*PI/180)).normalized()
#		impulso.x *= sinal_da_direcao
#		apply_impulse( Vector2(), impulso)

func _estagio3(delta):
	if pode_pular and no_chao:
		if contador_para_flechas >= 0:
			_atirar_flechas()
			contador_para_flechas = 0
		else:
			contador_para_flechas += 1
		
#		pode_pular = false
		randomize()
		get_tree().create_timer(rand_range(tempo_min2, tempo_max2)).connect('timeout', self, '_pula_peao_anim')
		#		timer = 0
#		random_timer = rand_range(tempo_min0,tempo_max0)

		var angulo = rand_range(30, 65)
		var impulso = rand_range(750, 1350) * Vector2(cos(angulo*PI/180), - sin(angulo*PI/180)).normalized()
		impulso.x *= sinal_da_direcao
		apply_impulse( Vector2(), impulso)

func _estagio4(delta):
	if contador_de_tocou_o_chao >= 3:
		_pula_peao()
		contador_de_tocou_o_chao = 0
			
#	if pode_pular and no_chao:
##		if contador_para_flechas >= 0:
##			_atirar_flechas()
##			contador_para_flechas = 0
##		else:
##			contador_para_flechas += 1
#
#		pode_pular = false
#		randomize()
#		get_tree().create_timer(rand_range(tempo_min2, tempo_max2)).connect('timeout', self, '_pula_peao')
#		#		timer = 0
##		random_timer = rand_range(tempo_min0,tempo_max0)
#
#		var angulo = rand_range(30, 65)
#		var impulso = rand_range(550, 1350) * Vector2(cos(angulo*PI/180), - sin(angulo*PI/180)).normalized()
#		impulso.x *= sinal_da_direcao
#		apply_impulse( Vector2(), impulso)
#		_atirar_flechas()
		
func _pode_pular():
	pode_pular = true

func _pula_peao_anim():
	animacao = 'Jumping'
	pass

func _pula_peao():
	if estagio == 0:
		var angulo = rand_range(30, 55)
		var impulso = rand_range(550, 1050) * Vector2(cos(angulo*PI/180), - sin(angulo*PI/180)).normalized()
		impulso.x *= sinal_da_direcao
		apply_impulse( Vector2(), impulso)
		pass
	elif estagio == 1:
		var angulo = rand_range(30, 65)
		var impulso = rand_range(750, 1350) * Vector2(cos(angulo*PI/180), - sin(angulo*PI/180)).normalized()
		impulso.x *= sinal_da_direcao
		apply_impulse( Vector2(), impulso)
		pass
	elif estagio == 2:
		var angulo = rand_range(30, 65)
		var impulso = rand_range(550, 1350) * Vector2(cos(angulo*PI/180), - sin(angulo*PI/180)).normalized()
		impulso.x *= sinal_da_direcao
		apply_impulse( Vector2(), impulso)
	elif estagio == 3:
		var angulo = rand_range(30, 65)
		var impulso = rand_range(0, 5) * Vector2(cos(angulo*PI/180), - sin(angulo*PI/180)).normalized()
		impulso.x *= sinal_da_direcao
		apply_impulse( Vector2(), impulso)
	elif estagio == 4:
		var angulo = rand_range(30, 65)
		var impulso = rand_range(0, 5) * Vector2(cos(angulo*PI/180), - sin(angulo*PI/180)).normalized()
		impulso.x *= sinal_da_direcao
		apply_impulse( Vector2(), impulso)
#		_atirar_flechas()

# ~~ ~~ ~~ ~~ Funcoes de ataque
func _atirar_flechas():
	var i = 0
	while i < parametro_de_flechas:
		i += 1
		var flecha = flecha_preload.instance()
		flecha.add_collision_exception_with(self)

		if -sinal_da_direcao == 1:
			flecha.position = self.get_position()
		else:
			flecha.position = self.get_position()

		flecha.linear_velocity = Vector2(-1000*sinal_da_direcao, 0).rotated((PI/4) + PI*i/(parametro_de_flechas/2))
	#		flecha.apply_impulse(Vector2(), Vector2(666*direcao_movimento, 0))
		get_parent().add_child(flecha)
		pass

#	#Aplicar gravidade -- usar isso aqui no ataque do dedede
#	if get_linear_velocity().y < 0:
#		gravity_scale = 0.2
#	else:
#		gravity_scale = 1
func _atualizar_estagio():
	estagio += 1
	if estagio == 1:
#		set_modulate(Color(0,1,1,1))
		vida_para_mudanca = 60
		pass
	elif estagio == 2:
#		set_modulate(Color(1,0,1,1))
		self.set_friction(0.5)
		parametro_de_flechas = 4
		vida_para_mudanca = 40
		pass
	elif estagio == 3:
#		set_modulate(Color(1,1,0,1))
#		self.set_bounce(0.005)
		parametro_de_flechas = 8
		contador_de_tocou_o_chao = 0
		IMPULSO_DO_PULO = 1500
		vida_para_mudanca = 20
		pass
	elif estagio == 4:
#		set_modulate(Color(0,1,0,1))
		parametro_de_flechas = 10
		contador_de_tocou_o_chao = 0
		vida_para_mudanca = -100
		pass


func _causar_dano(dano):
	if vida > 0:
		vida -= dano
		texto.set_text(str(vida))
		if vida < vida_para_mudanca:
			_atualizar_estagio()
			invencibilidade = true
	else:
		set_process(false)
		get_node('AnimationPlayer').play('Dying')
#		body_set_mode(self, 1)
#		queue_free()
	pass

func _on_Area2D_body_entered( body ):
	if body.is_in_group('player'):
		pos_player_horizontal = body.position.x
		
	pass # replace with function body
	
func _invencibilidade(delta):

	if timer_da_invencibilidade_comecou == false:
		get_tree().create_timer(1.0).connect('timeout', self, '_parar_invencibilidade')
		get_node('Area2D/CollisionShape2D').set_disabled(true)
		timer_da_invencibilidade_comecou = true
		self.set_collision_layer(3)
		self.set_collision_mask(3)
		
#		self.set_modulate(Color(1,0,1,1))
	if piscou == true:
		piscou = false
		get_tree().create_timer(0.1).connect('timeout', self, '_piscar_na_invencibilidade')
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
	self.set_modulate(Color(1,0,1,1))
	pass