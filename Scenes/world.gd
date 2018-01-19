extends WorldEnvironment

var posicao_inicial = Vector2()
onready var fases = [preload('res://Scenes/Fases/Intro/1-1n.tscn'), preload('res://Scenes/Fases/Intro/2-1n.tscn')]
onready var posicoes = [get_node('1'), get_node('2')]

func _ready():
	for i in fases:
		var chunk = i.instance()
		chunk.set_position(posicao_inicial)
		add_child(chunk)
		posicao_inicial.x += 3060
#	for i in range(4):
##		randomize()
##		var index = round(randi() % 2)
##		print(str(fase))
#		var chunk = fases[i].instance()
#		chunk.set_position(posicao_inicial)
#		add_child(chunk)
#		posicao_inicial.x += 4000
	
#	set_process(true)
	pass
#
#func _process(delta):
#	print(get_node('VisibilityNotifier2D').is_on_screen())
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
