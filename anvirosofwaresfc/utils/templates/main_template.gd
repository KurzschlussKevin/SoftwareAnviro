extends Control

# --- SZENEN REFERENZEN ---
var scene_dashboard = preload("res://scene/dashboard/dashboard.tscn")
var scene_kunden = preload("res://scene/kundenverwaltung/kundenverwaltung.tscn")
var scene_vertrieb = preload("res://scene/vertriebsbereich/vertriebsbereich.tscn")
var scene_planung = preload("res://scene/planung/planung.tscn")
var scene_mitarbeiter = preload("res://scene/mitarbeiterverwaltung/mitarbeiterverwaltung.tscn")
var scene_arbeitsnachweis = preload("res://scene/arbeitsnachweis/arbeitsnachweis.tscn")
var scene_dokumentation = preload("res://scene/dokumentation/dokumentation.tscn")
var scene_export = preload("res://scene/reportexport/report_export.tscn")

# --- UI REFERENZEN ---
@onready var content_container = $HBoxContainer/ContentArea/MainContent/SceneContainer
@onready var page_title = $HBoxContainer/ContentArea/TopBar/Margin/HBox/PageTitle

# Sidebar Buttons
@onready var btn_dashboard = $HBoxContainer/Sidebar/VBox/NavButtons/BtnDashboard
@onready var btn_kunden = $HBoxContainer/Sidebar/VBox/NavButtons/BtnKunden
@onready var btn_vertrieb = $HBoxContainer/Sidebar/VBox/NavButtons/BtnVertrieb
@onready var btn_planung = $HBoxContainer/Sidebar/VBox/NavButtons/BtnPlanung
@onready var btn_mitarbeiter = $HBoxContainer/Sidebar/VBox/NavButtons/BtnMitarbeiter
@onready var btn_arbeitsnachweis = $HBoxContainer/Sidebar/VBox/NavButtons/BtnArbeitsnachweis
@onready var btn_dokumentation = $HBoxContainer/Sidebar/VBox/NavButtons/BtnDokumentation
@onready var btn_export = $HBoxContainer/Sidebar/VBox/NavButtons/BtnExport
@onready var btn_logout = $HBoxContainer/Sidebar/VBox/LogoutArea/BtnLogout

func _ready():
	# Navigation Sidebar
	btn_dashboard.pressed.connect(func(): load_scene(scene_dashboard, "Dashboard"))
	btn_kunden.pressed.connect(func(): load_scene(scene_kunden, "Kundenverwaltung"))
	btn_vertrieb.pressed.connect(func(): load_scene(scene_vertrieb, "Vertriebsbereich"))
	btn_planung.pressed.connect(func(): load_scene(scene_planung, "Einsatzplanung"))
	btn_mitarbeiter.pressed.connect(func(): load_scene(scene_mitarbeiter, "Mitarbeiter"))
	
	btn_arbeitsnachweis.pressed.connect(func(): load_scene(scene_arbeitsnachweis, "Arbeitsnachweis"))
	btn_dokumentation.pressed.connect(func(): load_scene(scene_dokumentation, "Dokumentation"))
	btn_export.pressed.connect(func(): load_scene(scene_export, "Export & Berichte"))
	
	btn_logout.pressed.connect(_on_logout_pressed)
	
	# Start
	load_scene(scene_dashboard, "Dashboard")

func load_scene(scene_resource: PackedScene, title: String):
	# 1. Titel setzen
	page_title.text = title
	
	# 2. Alte Szene entfernen
	for child in content_container.get_children():
		child.queue_free()
	
	# 3. Neue Szene instanziieren
	var new_scene = scene_resource.instantiate()
	
	# Layout Einstellungen
	new_scene.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	new_scene.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	# --- NEU: SIGNAL VERBINDEN ---
	# Wenn die Szene das Signal 'request_navigation' hat (wie unser Dashboard), verbinden wir es
	if new_scene.has_signal("request_navigation"):
		new_scene.request_navigation.connect(_on_navigation_requested)
	
	content_container.add_child(new_scene)

# --- NEU: NAVIGATIONS-HANDLER ---
func _on_navigation_requested(target_name: String):
	match target_name:
		"Kundenverwaltung":
			load_scene(scene_kunden, "Kundenverwaltung")
		"Vertriebsbereich":
			load_scene(scene_vertrieb, "Vertriebsbereich")
		"Einsatzplanung":
			load_scene(scene_planung, "Einsatzplanung")
		"Mitarbeiter":
			load_scene(scene_mitarbeiter, "Mitarbeiter")
		"Arbeitsnachweis":
			load_scene(scene_arbeitsnachweis, "Arbeitsnachweis")
		"Dokumentation":
			load_scene(scene_dokumentation, "Dokumentation")
		"Export & Berichte":
			load_scene(scene_export, "Export & Berichte")
		"Dashboard":
			load_scene(scene_dashboard, "Dashboard")
		_:
			print("Unbekanntes Ziel: ", target_name)

func _on_logout_pressed():
	print("Logout gedrückt")
	# get_tree().change_scene_to_file("res://scene/auth/auth_controlling.tscn")
