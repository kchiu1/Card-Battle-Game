extends CanvasLayer

var duration = 0.6

func _ready():
	var screen = get_viewport().get_visible_rect().size
	
	$TopBar.size = Vector2(screen.x, screen.y / 2)
	$TopBar.position = Vector2(0, -screen.y / 2)  # hidden above screen
	
	$BottomBar.size = Vector2(screen.x, screen.y / 2)
	$BottomBar.position = Vector2(0, screen.y)  # hidden below screen
	
	$TopBar.visible = false
	$BottomBar.visible = false

func transition_to(path: String):
	var screen = get_viewport().get_visible_rect().size
	await get_tree().create_timer(0.25).timeout
	$TopBar.visible = true
	$BottomBar.visible = true
	
	# Close
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property($TopBar, "position:y", 0, duration).set_ease(Tween.EASE_IN)
	tween.tween_property($BottomBar, "position:y", screen.y / 2, duration).set_ease(Tween.EASE_IN)
	await tween.finished
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file(path)
	
	# Open
	var tween2 = create_tween()
	tween2.set_parallel(true)
	tween2.tween_property($TopBar, "position:y", -screen.y / 2, duration).set_ease(Tween.EASE_OUT)
	tween2.tween_property($BottomBar, "position:y", screen.y, duration).set_ease(Tween.EASE_OUT)
	await tween2.finished
	
	$TopBar.visible = false
	$BottomBar.visible = false
