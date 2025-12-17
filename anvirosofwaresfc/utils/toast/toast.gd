extends PanelContainer

func setup(type: String, message: String):
	# Nachricht setzen
	%LabelMsg.text = message
	
	# Style anpassen (Farben)
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
	# 1. SOFORT SICHTBAR MACHEN (Wichtig!)
	modulate.a = 1.0
	
	# 2. Debug-Ausgabe, damit wir wissen, dass er lebt
	print("Toast wurde erstellt und sollte sichtbar sein!")

	# 3. Wartezeit (4 Sekunden)
	var timer = get_tree().create_timer(4.0)
	await timer.timeout
	
	# 4. Langsam ausblenden (per Code, ohne AnimationPlayer)
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	await tween.finished
	
	# 5. Löschen
	queue_free()
