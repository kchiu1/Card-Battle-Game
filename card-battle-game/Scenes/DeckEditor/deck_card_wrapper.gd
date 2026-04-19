extends Control

var on_click: Callable

# Called by Card._ready() - must exist on parent
func connect_card_signals(_card):
	pass  # clicks handled via _gui_input below

func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if on_click:
			on_click.call()
