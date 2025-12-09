extends Control

# --- SZENEN REFERENZEN ---
# Alle Pfade zu den Modulen
var scene_dashboard = preload("res://scene/dashboard/dashboard.tscn")
var scene_kunden = preload("res://scene/kundenverwaltung/kundenverwaltung.tscn")
var scene_vertrieb = preload("res://scene/vertriebsbereich/vertriebsbereich.tscn")
var scene_mitarbeiter = preload("res://scene/mitarbeiterverwaltung/mitarbeiterverwaltung.tscn")
var scene_arbeitsnachweis = preload("res://scene/arbeitsnachweis/arbeitsnachweis.tscn")
var scene_dokumentation = preload("res://scene/dokumentation/dokumentation.tscn")
var scene_export = preload("res://scene/reportexport/report_export.tscn")

# --- UI REFERENZEN ---
@onready var content_container = $HBoxContainer/ContentArea/MainContent/SceneContainer
@onready var page_title = $HBoxContainer/ContentArea/TopBar/Margin/HBox/PageTitle

# Buttons in der Sidebar
@onready var btn_dashboard = $HBoxContainer/Sidebar/VBox/NavButtons/BtnDashboard
@onready var btn_kunden = $HBoxContainer/Sidebar/VBox/NavButtons/BtnKunden
@onready var btn_vertrieb = $HBoxContainer/Sidebar/VBox/NavButtons/BtnVertrieb
@onready var btn_mitarbeiter = $HBoxContainer/Sidebar/VBox/NavButtons/BtnMitarbeiter
@onready var btn_arbeitsnachweis = $HBoxContainer/Sidebar/VBox/NavButtons/BtnArbeitsnachweis
@onready var btn_dokumentation = $HBoxContainer/Sidebar/VBox/NavButtons/BtnDokumentation
@onready var btn_export = $HBoxContainer/Sidebar/VBox/NavButtons/BtnExport

@onready var btn_logout = $HBoxContainer/Sidebar/VBox/LogoutArea/BtnLogout

func _ready():
	# 1. Signale verbinden
	btn_dashboard.pressed.connect(func(): load_scene(scene_dashboard, "Dashboard"))
	btn_kunden.pressed.connect(func(): load_scene(scene_kunden, "Kundenverwaltung"))
	btn_vertrieb.pressed.connect(func(): load_scene(scene_vertrieb, "Vertriebsbereich"))
	btn_mitarbeiter.pressed.connect(func(): load_scene(scene_mitarbeiter, "Mitarbeiter"))
	
	# Operative Module
	btn_arbeitsnachweis.pressed.connect(func(): load_scene(scene_arbeitsnachweis, "Arbeitsnachweis"))
	btn_dokumentation.pressed.connect(func(): load_scene(scene_dokumentation, "Dokumentation"))
	btn_export.pressed.connect(func(): load_scene(scene_export, "Export & Berichte"))
	
	btn_logout.pressed.connect(_on_logout_pressed)
	
	# 2. Start-Szene laden
	load_scene(scene_dashboard, "Dashboard")

func load_scene(scene_resource: PackedScene, title: String):
	# Titel oben ändern
	page_title.text = title
	
	# Alte Szene entfernen
	for child in content_container.get_children():
		child.queue_free()
	
	# Neue Szene erstellen und hinzufügen
	var new_scene = scene_resource.instantiate()
	
	# WICHTIG: Damit die Szenen den Platz ausfüllen
	new_scene.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	new_scene.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	content_container.add_child(new_scene)

func _on_logout_pressed():
	print("Logout gedrückt - Hier käme der Szenenwechsel zum Login")
	# get_tree().change_scene_to_file("res://scene/auth/auth_controlling.tscn")
