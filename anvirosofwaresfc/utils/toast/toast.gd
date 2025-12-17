extends PanelContainer

func setup(type: String, message: String):
	%LabelMsg.text = message
	
	# Hole den Style und dupliziere ihn, damit wir ihn für diese Instanz ändern können
	var style = get_theme_stylebox("panel").duplicate()
	
	if type == "success":
		style.border_color = Color(0.2, 0.8, 0.4, 1) # Grün
		%Icon.modulate = Color(0.2, 0.8, 0.4, 1)
	elif type == "error":
		style.border_color = Color(1.0, 0.3, 0.3, 1) # Rot
		%Icon.modulate = Color(1.0, 0.3, 0.3, 1)
	elif type == "info":
		style.border_color = Color(0.2, 0.6, 1.0, 1) # Blau
		%Icon.modulate = Color(0.2, 0.6, 1.0, 1)
		
	add_theme_stylebox_override("panel", style)

func _ready():
	# Warten bis die Animation "show" fertig ist und dann löschen
	if %AnimationPlayer.has_animation("show"):
		await %AnimationPlayer.animation_finished
	queue_free()
