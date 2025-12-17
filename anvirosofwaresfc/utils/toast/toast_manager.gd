extends CanvasLayer

# Pfad zur Toast-Szene
const TOAST_SCENE = preload("res://utils/toast/toast.tscn")

var toast_container: VBoxContainer

func _ready():
	# Layer hoch setzen, damit es über allem schwebt
	layer = 128
	
	# MarginContainer für Abstand und Positionierung
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_right", 20)
	
	# MOUSE_FILTER_IGNORE ist wichtig, damit man 'durchklicken' kann
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# WICHTIG: Positionierung oben rechts
	margin.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	
	# DER FIX: Wir müssen nach LINKS wachsen, sonst ist der Toast außerhalb des Bildschirms!
	margin.grow_horizontal = Control.GROW_DIRECTION_BEGIN 
	
	# Hier sammeln sich die Toasts
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	# VBox muss auch die Maus ignorieren (außer die Toasts selbst vielleicht)
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	margin.add_child(vbox)
	add_child(margin)
	
	# Referenz merken
	toast_container = vbox

func show_success(msg: String):
	_spawn_toast("success", msg)

func show_error(msg: String):
	_spawn_toast("error", msg)

func show_info(msg: String):
	_spawn_toast("info", msg)

func _spawn_toast(type: String, msg: String):
	print("ToastManager: Spawning Toast...")
	var toast = TOAST_SCENE.instantiate()
	toast_container.add_child(toast)
	toast.setup(type, msg)
