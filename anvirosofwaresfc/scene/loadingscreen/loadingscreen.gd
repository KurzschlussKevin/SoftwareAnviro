extends Control

@onready var progress_bar = %ProgressBar
@onready var label_status = %LabelStatus

# Ziel-Szene (Das Dashboard)
const MAIN_SCENE_PATH = "res://utils/templates/main_template.tscn"

func _ready():
	get_window().size = Vector2i(1024, 600)
	get_window().move_to_center()
	start_loading_sequence()

func start_loading_sequence():
	# Wir simulieren hier Ladeschritte mit einem Tween
	var tween = create_tween()
	
	# Schritt 1: 0% bis 30% (Schnell)
	tween.tween_callback(func(): label_status.text = "Verbinde mit Datenbank...")
	tween.tween_property(progress_bar, "value", 30.0, 0.5).set_trans(Tween.TRANS_CUBIC)
	
	# Schritt 2: 30% bis 70% (Etwas langsamer)
	tween.tween_callback(func(): label_status.text = "Lade Benutzerprofile...")
	tween.tween_property(progress_bar, "value", 70.0, 1.0).set_trans(Tween.TRANS_LINEAR)
	
	# Schritt 3: 70% bis 100% (Endspurt)
	tween.tween_callback(func(): label_status.text = "Finalisiere Dashboard...")
	tween.tween_property(progress_bar, "value", 100.0, 0.4).set_trans(Tween.TRANS_CUBIC)
	
	# Abschluss: Szene wechseln
	tween.tween_callback(_on_loading_complete)

func _on_loading_complete():
	# Kurz warten bei 100%, damit es der Nutzer sieht
	await get_tree().create_timer(0.2).timeout
	get_tree().change_scene_to_file(MAIN_SCENE_PATH)
