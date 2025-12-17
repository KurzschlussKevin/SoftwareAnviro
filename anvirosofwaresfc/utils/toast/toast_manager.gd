extends CanvasLayer

# Pfad zur Toast-Szene
const TOAST_SCENE = preload("res://utils/toast/toast.tscn")

var toast_container: VBoxContainer

func _ready():
	# Wir erstellen einen Container, der immer ganz oben liegt (Layer 100)
	layer = 128
	
	toast_container = VBoxContainer.new()
	toast_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	toast_container.anchor_right = 1.0 # Volle Breite
	toast_container.anchor_bottom = 1.0 # Volle Höhe
	
	# Positionierung: Oben rechts mit etwas Abstand
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	
	# Hier sammeln sich die Toasts
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	
	margin.add_child(vbox)
	add_child(margin)
	
	# Referenz merken
	toast_container = vbox

func show_success(msg: String):
	_spawn_toast("success", msg)

func show_error(msg: String):
	_spawn_toast("error", msg)

func show_info(msg: String):
	print("ToastManager: show_info wurde aufgerufen mit: ", msg)
	_spawn_toast("info", msg)

func _spawn_toast(type: String, msg: String):
	print("ToastManager: Spawning Toast...")
	var toast = TOAST_SCENE.instantiate()
	toast_container.add_child(toast)
	toast.setup(type, msg)
