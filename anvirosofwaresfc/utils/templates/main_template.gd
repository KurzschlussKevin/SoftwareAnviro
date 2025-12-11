extends Control

var scene_dashboard = preload("res://scene/dashboard/dashboard.tscn")
var scene_kunden = preload("res://scene/kundenverwaltung/kundenverwaltung.tscn")
var scene_vertrieb = preload("res://scene/vertriebsbereich/vertriebsbereich.tscn")
var scene_profil = preload("res://scene/profil/profil.tscn")
var scene_planung = preload("res://scene/planung/planung.tscn")
var scene_mitarbeiter = preload("res://scene/mitarbeiterverwaltung/mitarbeiterverwaltung.tscn")
var scene_arbeitsnachweis = preload("res://scene/arbeitsnachweis/arbeitsnachweis.tscn")
var scene_dokumentation = preload("res://scene/dokumentation/dokumentation.tscn")
var scene_export = preload("res://scene/reportexport/report_export.tscn")

@onready var content_container = $HBoxContainer/ContentArea/MainContent/SceneContainer
@onready var page_title = $HBoxContainer/ContentArea/TopBar/Margin/HBox/PageTitle

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
	btn_dashboard.pressed.connect(func(): load_scene(scene_dashboard, "Dashboard"))
	btn_kunden.pressed.connect(func(): load_scene(scene_kunden, "Kundenverwaltung"))
	btn_vertrieb.pressed.connect(func(): load_scene(scene_vertrieb, "Vertriebsbereich"))
	btn_planung.pressed.connect(func(): load_scene(scene_planung, "Einsatzplanung"))
	btn_mitarbeiter.pressed.connect(func(): load_scene(scene_mitarbeiter, "Mitarbeiter"))
	btn_arbeitsnachweis.pressed.connect(func(): load_scene(scene_arbeitsnachweis, "Arbeitsnachweis"))
	btn_dokumentation.pressed.connect(func(): load_scene(scene_dokumentation, "Dokumentation"))
	btn_export.pressed.connect(func(): load_scene(scene_export, "Export & Berichte"))
	
	btn_logout.pressed.connect(func(): print("Logout"))
	
	load_scene(scene_dashboard, "Dashboard")

func load_scene(scene_resource: PackedScene, title: String) -> Node:
	page_title.text = title
	for child in content_container.get_children():
		child.queue_free()
	
	var new_scene = scene_resource.instantiate()
	new_scene.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	new_scene.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	if new_scene.has_signal("request_navigation"):
		new_scene.request_navigation.connect(_on_navigation_requested)
	
	content_container.add_child(new_scene)
	return new_scene

func _on_navigation_requested(target_name: String, mode: String = ""):
	var current_scene = null
	
	match target_name:
		"Kundenverwaltung":
			current_scene = load_scene(scene_kunden, "Kundenverwaltung")
			if mode == "create_customer" and current_scene.has_method("start_create_mode"):
				current_scene.start_create_mode()
				
		"Vertriebsbereich":
			current_scene = load_scene(scene_vertrieb, "Vertriebsbereich")
			if mode == "create_offer" and current_scene.has_method("start_offer_selection"):
				current_scene.start_offer_selection()
		
		"Profil":
			load_scene(scene_profil, "Mein Profil")
			
		"Export & Berichte":
			load_scene(scene_export, "Export & Berichte")
			
		"Dashboard": load_scene(scene_dashboard, "Dashboard")
		_: print("Unbekanntes Ziel: ", target_name)
