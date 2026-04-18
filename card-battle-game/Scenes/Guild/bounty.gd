extends Node2D

var texture
var target_box_size = Vector2(102, 61)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func fit_sprite_to_box(texture_path: String):
	# 1. Load the texture resource from the path
	var new_texture = load(texture_path)
	
	if new_texture:
		# 2. Update the sprite's texture
		$EnemySprite.texture = new_texture
		
		var tex_size = $EnemySprite.texture.get_size()
	
		# 1. Calculate how much we'd need to scale for width and height separately
		var scale_x = target_box_size.x / tex_size.x
		var scale_y = target_box_size.y / tex_size.y

		# 2. Pick the SMALLEST ratio. 
		# Using the smaller one ensures the sprite fits entirely inside.
		# Using the larger one would "fill" the box but crop the edges.
		var uniform_factor = min(scale_x, scale_y)
	
		# 3. Apply the same value to both X and Y (Locked Proportions)
		$EnemySprite.scale = Vector2(uniform_factor, uniform_factor)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
