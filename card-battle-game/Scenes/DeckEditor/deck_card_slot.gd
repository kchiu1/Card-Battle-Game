extends Node2D

var on_click: Callable

func connect_card_signals(card):
	if card.has_node("Area2D"):
		card.get_node("Area2D").input_event.connect(func(_vp, event, _idx):
			if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				if on_click: on_click.call()
		)
