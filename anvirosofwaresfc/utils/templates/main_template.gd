extends Control

# --- SZENEN PRELOADS (Pfade korrigiert) ---
var scene_dashboard = preload("res://scene/dashboard/dashboard.tscn")
var scene_kunden = preload("res://scene/kundenverwaltung/kundenverwaltung.tscn")
var scene_vertrieb = preload("res://scene/vertriebsbereich/vertriebsbereich.tscn")
var scene_profil = preload("res://scene/profil/profil.tscn")
var scene_planung = preload("res://scene/planung/planung.tscn")
var scene_mitarbeiter = preload("res://scene/mitarbeiterverwaltung/mitarbeiterverwaltung.tscn")
var scene_arbeitsnachweis = preload("res://scene/arbeitsnachweis/arbeitsnachweis.tscn")
var scene_dokumentation = preload("res://scene/dokumentation/dokumentation.tscn")
var scene_export = preload("res://scene/reportexport/report_export.tscn")
var scene_einstellungen = preload("res://scene/einstellungen/einstellungen.tscn")
var scene_pruefmittel = preload("res://scene/pruefmittel/pruefmittel.tscn")

# Alert Center
# HINWEIS: Stelle sicher, dass die Datei unter res://utils/alerts/alert_center.tscn existiert
var scene_alert_center = preload("res://utils/alert_center/alert_center.tscn")
var alert_popup_instance = null

# --- UI REFERENZEN ---
@onready var content_container = $HBoxContainer/ContentArea/MainContent/SceneContainer
@onready var page_title = $HBoxContainer/ContentArea/TopBar/Margin/HBox/PageTitle

# Sidebar Navigation
@onready var btn_dashboard = $HBoxContainer/Sidebar/VBox/NavButtons/BtnDashboard
@onready var btn_kunden = $HBoxContainer/Sidebar/VBox/NavButtons/BtnKunden
@onready var btn_vertrieb = $HBoxContainer/Sidebar/VBox/NavButtons/BtnVertrieb
@onready var btn_planung = $HBoxContainer/Sidebar/VBox/NavButtons/BtnPlanung
@onready var btn_mitarbeiter = $HBoxContainer/Sidebar/VBox/NavButtons/BtnMitarbeiter
@onready var btn_arbeitsnachweis = $HBoxContainer/Sidebar/VBox/NavButtons/BtnArbeitsnachweis
@onready var btn_dokumentation = $HBoxContainer/Sidebar/VBox/NavButtons/BtnDokumentation
@onready var btn_export = $HBoxContainer/Sidebar/VBox/NavButtons/BtnExport
@onready var btn_einstellungen = $HBoxContainer/Sidebar/VBox/NavButtons/BtnEinstellungen
@onready var btn_pruefmittel = $HBoxContainer/Sidebar/VBox/NavButtons/Btnpruefmittel

# Sidebar Footer
@onready var btn_logout = $HBoxContainer/Sidebar/VBox/LogoutArea/BtnLogout

# Alert Header
@onready var btn_alerts = $HBoxContainer/ContentArea/TopBar/Margin/HBox/AlertButtonContainer/BtnAlerts
@onready var alert_badge_container = $HBoxContainer/ContentArea/TopBar/Margin/HBox/AlertButtonContainer/AlertBadge
@onready var lbl_alert_count = $HBoxContainer/ContentArea/TopBar/Margin/HBox/AlertButtonContainer/AlertBadge/LabelCount


func _ready():
	# --- FENSTER-LOGIK (WICHTIG!) ---
	var win = get_window()
	
	# 1. Interne Skalierung auf Full HD setzen
	win.content_scale_size = Vector2i(1920, 1080)
	win.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	win.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND
	
	# 2. Fenster maximieren
	win.mode = Window.MODE_MAXIMIZED
	
	# --- NAVIGATION VERBINDEN ---
	if btn_dashboard: btn_dashboard.pressed.connect(func(): load_scene(scene_dashboard, "Dashboard"))
	if btn_kunden: btn_kunden.pressed.connect(func(): load_scene(scene_kunden, "Kundenverwaltung"))
	if btn_vertrieb: btn_vertrieb.pressed.connect(func(): load_scene(scene_vertrieb, "Vertriebsbereich"))
	if btn_planung: btn_planung.pressed.connect(func(): load_scene(scene_planung, "Einsatzplanung"))
	if btn_mitarbeiter: btn_mitarbeiter.pressed.connect(func(): load_scene(scene_mitarbeiter, "Mitarbeiter"))
	if btn_arbeitsnachweis: btn_arbeitsnachweis.pressed.connect(func(): load_scene(scene_arbeitsnachweis, "Arbeitsnachweis"))
	if btn_dokumentation: btn_dokumentation.pressed.connect(func(): load_scene(scene_dokumentation, "Dokumentation"))
	if btn_export: btn_export.pressed.connect(func(): load_scene(scene_export, "Export & Berichte"))
	if btn_einstellungen: btn_einstellungen.pressed.connect(func(): load_scene(scene_einstellungen, "Einstellungen"))
	if btn_pruefmittel: btn_pruefmittel.pressed.connect(func(): load_scene(scene_pruefmittel, "Prüfmittelverwaltung"))
	
	if btn_logout: 
		btn_logout.pressed.connect(_on_logout_pressed)
	
	# Alert Button
	if btn_alerts:
		btn_alerts.pressed.connect(_on_open_alerts)
	
	# Start-Szene laden
	load_scene(scene_dashboard, "Dashboard")
	
	# Alerts einmalig prüfen
	update_alerts_badge()


func _on_logout_pressed():
	# Pfad korrigiert:
	get_tree().change_scene_to_file("res://scene/auth/auth_controlling.tscn")


func load_scene(scene_resource: PackedScene, title: String) -> Node:
	page_title.text = title
	# Alte Szene entfernen
	for child in content_container.get_children():
		child.queue_free()
	
	# Neue Szene erstellen
	var new_scene = scene_resource.instantiate()
	new_scene.name = title 
	new_scene.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	new_scene.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	# Navigation-Signal weiterleiten
	if new_scene.has_signal("request_navigation"):
		new_scene.request_navigation.connect(_on_navigation_requested)
	
	content_container.add_child(new_scene)
	
	# Alerts aktualisieren
	update_alerts_badge()
	
	return new_scene


# Hilfsfunktion zum Finden der aktiven Szene
func get_loaded_scene(scene_title: String) -> Control:
	for child in content_container.get_children():
		if child.name == scene_title:
			return child
	return null


# --- ALERT SYSTEM ---
func update_alerts_badge():
	var total_alerts = 0
	
	# 1. Prüfmittel Alerts checken
	var temp_pruefmittel = scene_pruefmittel.instantiate()
	if temp_pruefmittel.has_method("get_overdue_pruefmittel_count"):
		total_alerts += temp_pruefmittel.get_overdue_pruefmittel_count()
	temp_pruefmittel.queue_free()

	# 2. Kunden Alerts checken
	var temp_kunden = scene_kunden.instantiate()
	if temp_kunden.has_method("get_overdue_customer_recall_count"):
		total_alerts += temp_kunden.get_overdue_customer_recall_count()
	temp_kunden.queue_free()
		
	# Badge Update
	if lbl_alert_count:
		lbl_alert_count.text = str(total_alerts)
		alert_badge_container.visible = total_alerts > 0


func _on_open_alerts():
	var all_alerts = []
	
	# Daten sammeln
	var temp_kunden = scene_kunden.instantiate()
	if temp_kunden.has_method("get_overdue_alerts"):
		all_alerts.append_array(temp_kunden.get_overdue_alerts())
	temp_kunden.queue_free()
	
	# Popup anzeigen
	if alert_popup_instance == null:
		alert_popup_instance = scene_alert_center.instantiate()
		add_child(alert_popup_instance)
		alert_popup_instance.set_anchors_preset(Control.PRESET_FULL_RECT)
		
	alert_popup_instance.show_alerts(all_alerts)


# --- INTERNE NAVIGATION ---
func _on_navigation_requested(target_name: String, mode: String = ""):
	var current_scene = null
	
	match target_name:
		"Kundenverwaltung":
			current_scene = load_scene(scene_kunden, "Kundenverwaltung")
			if mode == "create" and current_scene.has_method("start_new_customer"):
				current_scene.start_new_customer()
				
		"Vertriebsbereich":
			current_scene = load_scene(scene_vertrieb, "Vertriebsbereich")
			if mode == "create" and current_scene.has_method("start_new_offer"):
				current_scene.start_new_offer()
		
		"Profil":
			load_scene(scene_profil, "Mein Profil & Statistik")
			
		"Export & Berichte":
			load_scene(scene_export, "Export & Berichte")
			
		"Einsatzplanung": load_scene(scene_planung, "Einsatzplanung")
		"Dashboard": load_scene(scene_dashboard, "Dashboard")
		_: print("Unbekanntes Ziel: ", target_name)
