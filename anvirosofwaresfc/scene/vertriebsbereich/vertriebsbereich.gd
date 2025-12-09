extends Control

# Wir holen uns Referenzen zu den Containern
@onready var scroll_container = $HBox/RightCol/PositionsPanel/M/VBox/ScrollContainer
@onready var header_spacer = $HBox/RightCol/PositionsPanel/M/VBox/HeaderRow/HBox/ScrollbarSpacer

func _ready():
	# Wir warten einen kurzen Moment, bis Godot das UI fertig gezeichnet hat
	await get_tree().process_frame
	
	# Jetzt messen wir die TATSÄCHLICHE Breite des Scrollbalkens
	var scrollbar_width = scroll_container.get_v_scroll_bar().size.x
	
	# Und setzen den Platzhalter im Header auf exakt diese Breite
	# (Plus evtl. 1-2 Pixel Puffer, falls es optisch klemmt)
	if scrollbar_width > 0:
		header_spacer.custom_minimum_size.x = scrollbar_width
	else:
		# Fallback: Falls Scrollbalken noch versteckt, nehmen wir 12px (Standard)
		header_spacer.custom_minimum_size.x = 12.0
