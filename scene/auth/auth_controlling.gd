extends Control

# --- UI REFERENZEN ---
# Wir holen uns das CardPanel, um dessen Größe zu messen
@onready var card_panel = $CenterContainer/CardPanel

@onready var container_create = $CenterContainer/CardPanel/MarginContainer/AuthCreateAccount
@onready var container_login = $CenterContainer/CardPanel/MarginContainer/AuthLogin

@onready var btn_switch_to_login = $CenterContainer/CardPanel/MarginContainer/AuthCreateAccount/LoginInfoBox/LoginButton
@onready var btn_create = $CenterContainer/CardPanel/MarginContainer/AuthCreateAccount/CreateAccountBtn
@onready var input_login_mail = $CenterContainer/CardPanel/MarginContainer/AuthLogin/EMail
@onready var input_login_pass = $CenterContainer/CardPanel/MarginContainer/AuthLogin/Passwort
@onready var btn_login = $CenterContainer/CardPanel/MarginContainer/AuthLogin/LoginBtn

const LOADING_SCENE_PATH = "res://scene/loadingscreen/loadingscreen.tscn"

func _ready():
	# 1. Wir warten kurz, bis Godot das UI fertig gezeichnet hat
	# (Sonst ist die size noch 0 oder falsch)
	await get_tree().process_frame
	await get_tree().process_frame
	
	# 2. Wir holen die EXAKTE Größe deiner Login-Karte
	var node_size = card_panel.size
	
	# Optional: Ein kleiner Puffer (Rahmen), falls Schatten abgeschnitten werden
	# node_size += Vector2(20, 20) 
	
	# 3. Fenster anpassen
	var win = get_window()
	win.mode = Window.MODE_WINDOWED
	win.size = Vector2i(node_size.x, node_size.y)
	
	# 4. Interne Skalierung anpassen (damit es scharf bleibt)
	win.content_scale_size = Vector2i(node_size.x, node_size.y)
	win.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	win.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND
	
	# 5. Zentrieren
	win.move_to_center()
	
	# 6. CenterContainer anpassen, damit die Karte nicht verrutscht
	# Da das Fenster jetzt so klein wie die Karte ist, muss der Container folgen
	$CenterContainer.set_anchors_preset(Control.PRESET_FULL_RECT)

	# --- SIGNALE ---
	btn_switch_to_login.pressed.connect(_on_switch_to_login_pressed)
	btn_login.pressed.connect(_on_login_pressed)
	btn_create.pressed.connect(_on_create_pressed)
	input_login_pass.text_submitted.connect(func(t): _on_login_pressed())
	
	# Optional: Hintergrund entfernen, falls noch sichtbar
	# RenderingServer.set_default_clear_color(Color(0,0,0,0)) # Transparent (fortgeschritten)

func _on_switch_to_login_pressed():
	container_create.visible = false
	container_login.visible = true
	
	# Größe neu berechnen, da Login-Ansicht evtl. kleiner/größer ist als Register
	_resize_window_to_content()
	
	input_login_mail.grab_focus()

func _on_create_pressed():
	# Zurück zu Create wechseln
	# (Falls du das implementiert hast, hier analog _on_switch_to_login_pressed logic)
	pass

# Hilfsfunktion zum Nachjustieren der Größe beim Wechseln
func _resize_window_to_content():
	await get_tree().process_frame
	var new_size = card_panel.size
	var win = get_window()
	win.size = Vector2i(new_size.x, new_size.y)
	win.content_scale_size = Vector2i(new_size.x, new_size.y)
	win.move_to_center()

func _on_login_pressed():
	var mail = input_login_mail.text
	var pass_text = input_login_pass.text 
	
	if (mail == "admin" and pass_text == "admin") or (mail == "" and pass_text == ""): 
		_perform_login()
	else:
		shake_card()

func _perform_login():
	btn_login.text = "Lade..."
	btn_login.disabled = true
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file(LOADING_SCENE_PATH)

func shake_card():
	var tween = create_tween()
	var base_x = card_panel.position.x
	tween.tween_property(card_panel, "position:x", base_x - 10, 0.05)
	tween.tween_property(card_panel, "position:x", base_x + 10, 0.05)
	tween.tween_property(card_panel, "position:x", base_x, 0.05)
