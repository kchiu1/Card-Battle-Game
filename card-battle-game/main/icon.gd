extends Sprite2D

var time = 0.0
var start_y = 0.0

@export var amplitude = 20.0  
@export var frequency = 2.0 

func _ready():
	start_y = position.y   

func _process(delta):
	time += delta
	position.y = start_y + sin(time * frequency) * amplitude
