extends Control

# Pfad evtl. im Editor prüfen, je nachdem wie du die Nodes genau benannt hast
@onready var alert_container = $Panel/VBoxContainer/ScrollContainer/VBoxAlerts
@onready var btn_close = $Panel/VBoxContainer/BtnClose

func _ready():
	# Standardmäßig verstecken
	visible = false
	if btn_close:
		btn_close.pressed.connect(func(): visible = false)

func show_alerts(alert_list: Array):
	# Alte Einträge löschen
	for child in alert_container.get_children():
		child.queue_free()
		
	if alert_list.is_empty():
		var lbl = Label.new()
		lbl.text = "Keine aktuellen Warnungen."
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
		alert_container.add_child(lbl)
		visible = true
		return

	# Neue Einträge erstellen
	for item in alert_list:
		var p = PanelContainer.new()
		var style = StyleBoxFlat.new()
		
		# HIER WAR DIE ÄNDERUNG: Alpha von 0.5 auf 0.9 erhöht (dunklerer Hintergrund)
		style.bg_color = Color(0.1, 0.1, 0.1, 0.9) 
		
		style.border_width_left = 4
		style.border_color = item.get("color", Color.WHITE)
		style.corner_radius_top_right = 5
		style.corner_radius_bottom_right = 5
		style.content_margin_top = 8
		style.content_margin_bottom = 8
		style.content_margin_left = 12
		style.content_margin_right = 8
		p.add_theme_stylebox_override("panel", style)
		
		var vbox = VBoxContainer.new()
		
		var lbl_title = Label.new()
		lbl_title.text = item.get("title", "Info")
		lbl_title.add_theme_font_size_override("font_size", 15)
		lbl_title.add_theme_constant_override("outline_size", 0) # Kein Outline für bessere Lesbarkeit
		lbl_title.modulate = item.get("color", Color.WHITE)
		
		var lbl_text = Label.new()
		lbl_text.text = item.get("text", "")
		lbl_text.add_theme_font_size_override("font_size", 13)
		# Helleres Grau für besseren Kontrast auf dunklem Grund
		lbl_text.modulate = Color(0.9, 0.9, 0.9) 
		
		vbox.add_child(lbl_title)
		vbox.add_child(lbl_text)
		p.add_child(vbox)
		
		alert_container.add_child(p)
		
	visible = true
	move_to_front()
