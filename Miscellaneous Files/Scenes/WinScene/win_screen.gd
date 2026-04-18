extends CanvasLayer

signal restart_requested
signal main_menu_requested

@onready var title_label = $Panel/VBox/TitleLabel
@onready var subtitle_label = $Panel/VBox/SubtitleLabel
@onready var anim_player = $AnimationPlayer

func show_win():
	title_label.text = "VICTORY!"
	subtitle_label.text = "You defeated the enemy!"
	title_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.0))
	visible = true
	anim_player.play("appear")

func show_lose():
	title_label.text = "DEFEAT"
	subtitle_label.text = "The enemy won!"
	title_label.add_theme_color_override("font_color", Color(0.9, 0.2, 0.2))
	visible = true
	anim_player.play("appear")

func _on_main_menu_pressed() -> void:
	emit_signal("main_menu_requested")

func _on_restart_pressed() -> void:
	emit_signal("restart_requested")
