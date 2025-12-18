extends PanelContainer

signal resize_pressed_signal

# Wir entfernen @onready Variablen für setup(), um Timing-Fehler zu vermeiden
# und nutzen stattdessen get_node() direkt in der Funktion.

func setup(job, is_master, is_end):
	# Nodes direkt holen (sicherer als @onready in setup)
	var label_node = get_node("Label") 
	var resize_node = get_node("ResizeHandle")
	
	# 1. Farbe setzen
	var style = get_theme_stylebox("panel").duplicate()
	style.bg_color = job.col
	
	# 2. Design Logik
	if is_master:
		label_node.text = job.cust
		label_node.visible = true
		style.border_width_left = 2
		style.corner_radius_top_left = 6
		style.corner_radius_bottom_left = 6
	else:
		label_node.visible = false
		style.border_width_left = 0
		style.corner_radius_top_left = 0
		style.corner_radius_bottom_left = 0
		
	if is_end:
		style.border_width_right = 2
		style.corner_radius_top_right = 6
		style.corner_radius_bottom_right = 6
		resize_node.visible = true
		resize_node.mouse_filter = Control.MOUSE_FILTER_STOP
	else:
		style.border_width_right = 0
		style.corner_radius_top_right = 0
		style.corner_radius_bottom_right = 0
		resize_node.visible = false
		
	add_theme_stylebox_override("panel", style)

func _ready():
	# Signal verbinden, sobald der Node bereit ist
	var resize_node = get_node("ResizeHandle")
	if resize_node:
		resize_node.gui_input.connect(_on_handle_input)

func _on_handle_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		resize_pressed_signal.emit()
		accept_event()
