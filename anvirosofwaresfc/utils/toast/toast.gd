extends PanelContainer

func setup(type: String, message: String):
	%LabelMsg.text = message
	
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
	# WICHTIG: Den AnimationPlayer SOFORT löschen!
	# Sonst macht er den Toast unsichtbar.
	if has_node("AnimationPlayer"):
		get_node("AnimationPlayer").queue_free()
	
	# Sichtbarkeit erzwingen
	modulate.a = 1.0
	show()
	
	print("Toast: AnimationPlayer entfernt. Sichtbarkeit erzwungen.")

	# 4 Sekunden warten
	await get_tree().create_timer(4.0).timeout
	
	# Ausblenden
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	await tween.finished
	
	queue_free()
