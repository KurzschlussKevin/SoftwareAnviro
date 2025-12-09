extends Control

# --- SZENEN REFERENZEN ---
# Hier laden wir die Szenen vor, damit der Wechsel sofort passiert ohne Ladezeit.
var scene_dashboard = preload("res://scene/dashboard/dashboard.tscn")
var scene_kunden = preload("res://scene/kundenverwaltung/kundenverwaltung.tscn")
var scene_vertrieb = preload("res://scene/vertriebsbereich/vertriebsbereich.tscn")
var scene_mitarbeiter = preload("res://scene/mitarbeiterverwaltung/mitarbeiterverwaltung.tscn")
var scene_arbeitsnachweis = preload("res://scene/arbeitsnachweis/arbeitsnachweis.tscn")
# var scene_auth = preload("res://scene/auth/auth_controlling.tscn") # Falls du Logout brauchst

# --- UI REFERENZEN ---
@onready var content_container = $HBoxContainer/ContentArea/MainContent/SceneContainer
@onready var page_title = $HBoxContainer/ContentArea/TopBar/Margin/HBox/PageTitle

# Buttons (müssen im Inspektor oder per Code verknüpft sein, hier nutzen wir den expliziten Pfad)
@onready var btn_dashboard = $HBoxContainer/Sidebar/VBox/NavButtons/BtnDashboard
@onready var btn_kunden = $HBoxContainer/Sidebar/VBox/NavButtons/BtnKunden
@onready var btn_vertrieb = $HBoxContainer/Sidebar/VBox/NavButtons/BtnVertrieb
@onready var btn_mitarbeiter = $HBoxContainer/Sidebar/VBox/NavButtons/BtnMitarbeiter
@onready var btn_arbeitsnachweis = $HBoxContainer/Sidebar/VBox/NavButtons/BtnArbeitsnachweis
@onready var btn_logout = $HBoxContainer/Sidebar/VBox/LogoutArea/BtnLogout

func _ready():
	# 1. Signale verbinden (Was passiert beim Klick?)
	btn_dashboard.pressed.connect(func(): load_scene(scene_dashboard, "Dashboard"))
	btn_kunden.pressed.connect(func(): load_scene(scene_kunden, "Kundenverwaltung"))
	btn_vertrieb.pressed.connect(func(): load_scene(scene_vertrieb, "Vertriebsbereich"))
	btn_mitarbeiter.pressed.connect(func(): load_scene(scene_mitarbeiter, "Mitarbeiter"))
	
	# Neuer Button für Arbeitsnachweis
	btn_arbeitsnachweis.pressed.connect(func(): load_scene(scene_arbeitsnachweis, "Arbeitsnachweis"))
	
	btn_logout.pressed.connect(_on_logout_pressed)
	
	# 2. Start-Szene laden
	load_scene(scene_dashboard, "Dashboard")

func load_scene(scene_resource: PackedScene, title: String):
	# Titel oben ändern
	page_title.text = title
	
	# Alte Szene entfernen (falls eine da ist)
	for child in content_container.get_children():
		child.queue_free()
	
	# Neue Szene erstellen und hinzufügen
	var new_scene = scene_resource.instantiate()
	
	# WICHTIG: Damit die Szenen richtig im Container angezeigt werden
	new_scene.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	new_scene.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	content_container.add_child(new_scene)

func _on_logout_pressed():
	# Hier zurück zum Login wechseln
	# get_tree().change_scene_to_file("res://scene/auth/auth_controlling.tscn")
	print("Logout gedrückt")
